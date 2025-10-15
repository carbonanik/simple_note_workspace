import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

// Base class for serializable objects
abstract class Serializable {
  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
}

// Database entry wrapper
class DbEntry {
  final String key;
  final Uint8List data;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  DbEntry({
    required this.key,
    required this.data,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) : timestamp = timestamp ?? DateTime.now(),
       metadata = metadata ?? {};

  Map<String, dynamic> toJson() => {
    'key': key,
    'data': base64Encode(data),
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory DbEntry.fromJson(Map<String, dynamic> json) => DbEntry(
    key: json['key'],
    data: base64Decode(json['data']),
    timestamp: DateTime.parse(json['timestamp']),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );
}

// Query builder for filtering data
class QueryBuilder {
  final List<bool Function(DbEntry)> _filters = [];

  QueryBuilder where(String field, dynamic value) {
    _filters.add((entry) => entry.metadata[field] == value);
    return this;
  }

  QueryBuilder whereGreaterThan(String field, dynamic value) {
    _filters.add(
      (entry) =>
          entry.metadata[field] != null &&
          (entry.metadata[field] as Comparable).compareTo(value) > 0,
    );
    return this;
  }

  QueryBuilder whereLessThan(String field, dynamic value) {
    _filters.add(
      (entry) =>
          entry.metadata[field] != null &&
          (entry.metadata[field] as Comparable).compareTo(value) < 0,
    );
    return this;
  }

  QueryBuilder whereContains(String field, String value) {
    _filters.add(
      (entry) => entry.metadata[field]?.toString().contains(value) ?? false,
    );
    return this;
  }

  bool matches(DbEntry entry) {
    return _filters.every((filter) => filter(entry));
  }
}

// Efficient binary index entry
class IndexEntry {
  final int keyHash;
  final int position;
  final int length;

  IndexEntry({
    required this.keyHash,
    required this.position,
    required this.length,
  });

  // Each entry: 4 bytes (hash) + 8 bytes (position) + 4 bytes (length) = 16 bytes
  static const int entrySize = 16;

  void writeTo(ByteData buffer, int offset) {
    buffer.setInt32(offset, keyHash, Endian.big);
    buffer.setInt64(offset + 4, position, Endian.big);
    buffer.setInt32(offset + 12, length, Endian.big);
  }

  factory IndexEntry.readFrom(ByteData buffer, int offset) {
    return IndexEntry(
      keyHash: buffer.getInt32(offset, Endian.big),
      position: buffer.getInt64(offset + 4, Endian.big),
      length: buffer.getInt32(offset + 12, Endian.big),
    );
  }
}

// Main database class with optimized binary index
class SimpleHiveDB {
  static const String _dbFileName = 'simple_hive.db';
  static const String _indexFileName = 'simple_hive.idx';

  late String _dbPath;
  late String _indexPath;
  final Map<String, IndexEntry> _index = {}; // key -> index entry
  late RandomAccessFile _dbFile;
  bool _isInitialized = false;

  // Hash function for keys (simple but effective)
  int _hashKey(String key) {
    final bytes = utf8.encode(key);
    final digest = md5.convert(bytes);
    return digest.bytes[0] << 24 |
        digest.bytes[1] << 16 |
        digest.bytes[2] << 8 |
        digest.bytes[3];
  }

  // Initialize the database
  Future<void> init() async {
    if (_isInitialized) return;

    final directory = await getApplicationDocumentsDirectory();
    _dbPath = '${directory.path}/$_dbFileName';
    _indexPath = '${directory.path}/$_indexFileName';

    // Create or open database file
    final file = File(_dbPath);
    if (!await file.exists()) {
      await file.create();
    }
    _dbFile = await file.open(mode: FileMode.append);

    // Load index
    await _loadIndex();
    _isInitialized = true;
  }

  // Load binary index from disk
  Future<void> _loadIndex() async {
    final indexFile = File(_indexPath);
    if (!await indexFile.exists()) return;

    final bytes = await indexFile.readAsBytes();
    if (bytes.isEmpty) return;

    // First 4 bytes: number of entries
    final buffer = ByteData.sublistView(Uint8List.fromList(bytes));
    final entryCount = buffer.getInt32(0, Endian.big);

    // Read key-value pairs
    int offset = 4;
    for (int i = 0; i < entryCount; i++) {
      // Read key length
      final keyLength = buffer.getInt16(offset, Endian.big);
      offset += 2;

      // Read key
      final keyBytes = bytes.sublist(offset, offset + keyLength);
      final key = utf8.decode(keyBytes);
      offset += keyLength;

      // Read index entry
      final entry = IndexEntry.readFrom(buffer, offset);
      offset += IndexEntry.entrySize;

      _index[key] = entry;
    }
  }

  // Save binary index to disk
  Future<void> _saveIndex() async {
    // Calculate total size
    int totalSize = 4; // entry count
    for (final key in _index.keys) {
      totalSize += 2; // key length
      totalSize += utf8.encode(key).length; // key bytes
      totalSize += IndexEntry.entrySize; // index entry
    }

    final bytes = Uint8List(totalSize);
    final buffer = ByteData.sublistView(bytes);

    // Write entry count
    buffer.setInt32(0, _index.length, Endian.big);

    int offset = 4;
    for (final entry in _index.entries) {
      final keyBytes = utf8.encode(entry.key);

      // Write key length
      buffer.setInt16(offset, keyBytes.length, Endian.big);
      offset += 2;

      // Write key
      bytes.setRange(offset, offset + keyBytes.length, keyBytes);
      offset += keyBytes.length;

      // Write index entry
      entry.value.writeTo(buffer, offset);
      offset += IndexEntry.entrySize;
    }

    final indexFile = File(_indexPath);
    await indexFile.writeAsBytes(bytes);
  }

  // Store data with a key
  Future<void> put(
    String key,
    Uint8List data, {
    Map<String, dynamic>? metadata,
  }) async {
    await init();

    final entry = DbEntry(key: key, data: data, metadata: metadata);
    final serialized = jsonEncode(entry.toJson());
    final bytes = utf8.encode(serialized);
    final length = bytes.length;

    // Write length prefix and data
    final position = await _dbFile.position();
    await _dbFile.writeFrom(
      Uint8List.fromList([
        ...Uint8List(4)..buffer.asByteData().setUint32(0, length, Endian.big),
        ...bytes,
      ]),
    );
    await _dbFile.flush();

    // Update in-memory index
    _index[key] = IndexEntry(
      keyHash: _hashKey(key),
      position: position,
      length: length + 4,
    );

    // Save index periodically (batch writes)
    if (_index.length % 100 == 0) {
      await _saveIndex();
    }
  }

  // Store serializable object
  Future<void> putObject<T extends Serializable>(
    String key,
    T object, {
    Map<String, dynamic>? metadata,
  }) async {
    final json = jsonEncode(object.toJson());
    final data = Uint8List.fromList(utf8.encode(json));
    await put(key, data, metadata: metadata);
  }

  // Retrieve data by key
  Future<Uint8List?> get(String key) async {
    await init();

    final indexEntry = _index[key];
    if (indexEntry == null) return null;

    final file = File(_dbPath);
    final randomFile = await file.open();

    try {
      await randomFile.setPosition(indexEntry.position);

      // Read length prefix
      final lengthBytes = await randomFile.read(4);
      if (lengthBytes.length != 4) return null;

      final length = Uint8List.fromList(
        lengthBytes,
      ).buffer.asByteData().getUint32(0, Endian.big);

      // Read data
      final dataBytes = await randomFile.read(length);
      if (dataBytes.length != length) return null;

      final json = utf8.decode(dataBytes);
      final entry = DbEntry.fromJson(jsonDecode(json));

      return entry.data;
    } finally {
      await randomFile.close();
    }
  }

  // Retrieve serializable object
  Future<T?> getObject<T extends Serializable>(
    String key,
    T Function() factory,
  ) async {
    final data = await get(key);
    if (data == null) return null;

    final json = utf8.decode(data);
    final object = factory();
    object.fromJson(jsonDecode(json));
    return object;
  }

  // Get entry with metadata
  Future<DbEntry?> getEntry(String key) async {
    await init();

    final indexEntry = _index[key];
    if (indexEntry == null) return null;

    final file = File(_dbPath);
    final randomFile = await file.open();

    try {
      await randomFile.setPosition(indexEntry.position);

      final lengthBytes = await randomFile.read(4);
      if (lengthBytes.length != 4) return null;

      final length = Uint8List.fromList(
        lengthBytes,
      ).buffer.asByteData().getUint32(0, Endian.big);
      final dataBytes = await randomFile.read(length);
      if (dataBytes.length != length) return null;

      final json = utf8.decode(dataBytes);
      return DbEntry.fromJson(jsonDecode(json));
    } finally {
      await randomFile.close();
    }
  }

  // Delete entry by key
  Future<bool> delete(String key) async {
    await init();

    if (!_index.containsKey(key)) return false;

    _index.remove(key);
    // Don't save immediately, batch it
    return true;
  }

  // Query data with conditions
  Future<List<DbEntry>> query(QueryBuilder builder) async {
    await init();

    final results = <DbEntry>[];
    final file = File(_dbPath);
    final randomFile = await file.open();

    try {
      for (final entry in _index.entries) {
        await randomFile.setPosition(entry.value.position);

        final lengthBytes = await randomFile.read(4);
        if (lengthBytes.length != 4) continue;

        final length = Uint8List.fromList(
          lengthBytes,
        ).buffer.asByteData().getUint32(0, Endian.big);
        final dataBytes = await randomFile.read(length);
        if (dataBytes.length != length) continue;

        final json = utf8.decode(dataBytes);
        final dbEntry = DbEntry.fromJson(jsonDecode(json));

        if (builder.matches(dbEntry)) {
          results.add(dbEntry);
        }
      }
    } finally {
      await randomFile.close();
    }

    return results;
  }

  // Get all keys
  Future<List<String>> getAllKeys() async {
    await init();
    return _index.keys.toList();
  }

  // Get database stats
  Future<Map<String, dynamic>> getStats() async {
    await init();
    final dbFile = File(_dbPath);
    final indexFile = File(_indexPath);

    final dbSize = await dbFile.exists() ? await dbFile.length() : 0;
    final indexSize = await indexFile.exists() ? await indexFile.length() : 0;

    return {
      'entries': _index.length,
      'dbFileSize': dbSize,
      'indexFileSize': indexSize,
      'ratio': dbSize > 0
          ? '${(indexSize / dbSize * 100).toStringAsFixed(2)}%'
          : '0%',
      'dbPath': _dbPath,
      'indexPath': _indexPath,
    };
  }

  // Compact database (remove deleted entries)
  Future<void> compact() async {
    await init();

    final tempPath = '$_dbPath.tmp';
    final tempFile = File(tempPath);
    final tempWriter = await tempFile.open(mode: FileMode.write);
    final newIndex = <String, IndexEntry>{};

    try {
      final file = File(_dbPath);
      final reader = await file.open();

      try {
        for (final entry in _index.entries) {
          await reader.setPosition(entry.value.position);

          final lengthBytes = await reader.read(4);
          if (lengthBytes.length != 4) continue;

          final length = Uint8List.fromList(
            lengthBytes,
          ).buffer.asByteData().getUint32(0, Endian.big);
          final dataBytes = await reader.read(length);
          if (dataBytes.length != length) continue;

          final position = await tempWriter.position();
          await tempWriter.writeFrom([...lengthBytes, ...dataBytes]);

          newIndex[entry.key] = IndexEntry(
            keyHash: entry.value.keyHash,
            position: position,
            length: lengthBytes.length + dataBytes.length,
          );
        }
      } finally {
        await reader.close();
      }
    } finally {
      await tempWriter.close();
    }

    // Replace old file with compacted version
    await _dbFile.close();
    await File(_dbPath).delete();
    await tempFile.rename(_dbPath);

    _dbFile = await File(_dbPath).open(mode: FileMode.append);
    _index.clear();
    _index.addAll(newIndex);
    await _saveIndex();
  }

  // Flush index to disk
  Future<void> flush() async {
    await init();
    await _saveIndex();
  }

  // Close database
  Future<void> close() async {
    if (_isInitialized) {
      await _saveIndex(); // Save index before closing
      await _dbFile.close();
      _isInitialized = false;
    }
  }
}

// Example usage and test class
class Person extends Serializable {
  String name;
  int age;
  String email;

  Person({required this.name, required this.age, required this.email});

  @override
  Map<String, dynamic> toJson() => {'name': name, 'age': age, 'email': email};

  @override
  void fromJson(Map<String, dynamic> json) {
    name = json['name'];
    age = json['age'];
    email = json['email'];
  }

  @override
  String toString() => 'Person(name: $name, age: $age, email: $email)';
}

// Example usage
void runDatabase() async {
  final db = SimpleHiveDB();

  try {
    // Store binary data
    final imageData = Uint8List.fromList(List.generate(1000, (i) => i % 256));
    await db.put(
      'user_avatar',
      imageData,
      metadata: {'type': 'image', 'size': imageData.length},
    );

    // Store serializable objects
    final person1 = Person(name: 'Alice', age: 30, email: 'alice@example.com');
    final person2 = Person(name: 'Bob', age: 25, email: 'bob@example.com');

    await db.putObject(
      'person1',
      person1,
      metadata: {'department': 'engineering', 'active': true},
    );
    await db.putObject(
      'person2',
      person2,
      metadata: {'department': 'marketing', 'active': true},
    );

    for (var i = 0; i < 10000; i++) {
      final person = Person(
        name: 'User $i',
        age: 30,
        email: 'user$i@example.com',
      );
      await db.putObject(
        'person$i',
        person,
        metadata: {'department': 'engineering', 'active': true},
      );
    }

    // Flush to ensure index is saved
    await db.flush();

    // Retrieve data
    final retrievedImage = await db.get('user_avatar');
    print('Retrieved image size: ${retrievedImage?.length}');

    final retrievedPerson = await db.getObject(
      'person1',
      () => Person(name: '', age: 0, email: ''),
    );
    print('Retrieved person: $retrievedPerson');

    // Query data
    final query = QueryBuilder()
        .where('department', 'engineering')
        .where('active', true);

    final results = await db.query(query);
    print('Query results: ${results.length} entries');

    for (final result in results) {
      print('Key: ${result.key}, Metadata: ${result.metadata}');
    }

    // Get stats (now shows index efficiency)
    final stats = await db.getStats();
    print('Database stats:');
    print('  Entries: ${stats['entries']}');
    print('  DB size: ${stats['dbFileSize']} bytes');
    print('  Index size: ${stats['indexFileSize']} bytes');
    print('  Index/DB ratio: ${stats['ratio']}');

    // List all keys
    final keys = await db.getAllKeys();
    print('All keys: $keys');
  } finally {
    await db.close();
  }
}
