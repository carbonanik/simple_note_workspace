import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

// ============================================
// 1. BINARY SERIALIZATION
// ============================================

class BinarySerializer {
  // Serialize a map to binary format
  static Uint8List encode(Map<String, dynamic> data) {
    final jsonStr = jsonEncode(data);
    final jsonBytes = utf8.encode(jsonStr);
    final length = jsonBytes.length;

    // Format: [4 bytes length][data bytes]
    final buffer = ByteData(4 + length);
    buffer.setUint32(0, length, Endian.little);

    final result = buffer.buffer.asUint8List();
    result.setRange(4, 4 + length, jsonBytes);

    return result;
  }

  // Deserialize binary back to map
  static Map<String, dynamic> decode(Uint8List bytes) {
    final buffer = ByteData.sublistView(bytes);
    final length = buffer.getUint32(0, Endian.little);
    final jsonBytes = bytes.sublist(4, 4 + length);
    final jsonStr = utf8.decode(jsonBytes);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }
}

// ============================================
// 2. FILE STORAGE LAYER
// ============================================

class BinaryStorage {
  final File file;
  RandomAccessFile? _raf;
  bool _isOpen = false;

  BinaryStorage(String path) : file = File(path);

  Future<void> open() async {
    if (_isOpen) return;

    // Create parent directory if needed
    await file.parent.create(recursive: true);

    // Create file if doesn't exist
    if (!await file.exists()) {
      await file.create();
    }

    _raf = await file.open(mode: FileMode.append);
    _isOpen = true;
  }

  Future<int> write(Uint8List data) async {
    if (!_isOpen || _raf == null) {
      throw StateError('Storage not opened');
    }

    final offset = await _raf!.position();
    await _raf!.writeFrom(data);
    await _raf!.flush();
    return offset;
  }

  Future<Uint8List> read(int offset, int length) async {
    if (!_isOpen || _raf == null) {
      throw StateError('Storage not opened');
    }

    await _raf!.setPosition(offset);
    return Uint8List.fromList(await _raf!.read(length));
  }

  Future<int> length() async {
    return await file.length();
  }

  Future<void> close() async {
    if (_isOpen && _raf != null) {
      await _raf!.close();
      _isOpen = false;
    }
  }

  Future<void> clear() async {
    await close();
    if (await file.exists()) {
      await file.delete();
    }
  }
}

// ============================================
// 3. INDEX MANAGER
// ============================================

class IndexManager {
  final Map<String, int> _keyToOffset = {};
  final Map<String, Map<String, Set<String>>> _fieldIndexes = {};
  final File indexFile;

  IndexManager(String path) : indexFile = File(path);

  // Add entry to primary index
  void addKey(String key, int offset) {
    _keyToOffset[key] = offset;
  }

  // Get offset for a key
  int? getOffset(String key) => _keyToOffset[key];

  // Remove key from index
  void removeKey(String key) {
    _keyToOffset.remove(key);
  }

  // Add secondary index for field-based queries
  void indexField(String field, dynamic value, String key) {
    final valueStr = value.toString();
    _fieldIndexes.putIfAbsent(field, () => {});
    _fieldIndexes[field]!.putIfAbsent(valueStr, () => {});
    _fieldIndexes[field]![valueStr]!.add(key);
  }

  // Query by field value
  Set<String> queryByField(String field, dynamic value) {
    final valueStr = value.toString();
    return _fieldIndexes[field]?[valueStr] ?? {};
  }

  // Get all keys
  Iterable<String> getAllKeys() => _keyToOffset.keys;

  // Save index to disk
  Future<void> save() async {
    final data = {
      'keyToOffset': _keyToOffset,
      'fieldIndexes': _fieldIndexes.map(
        (field, values) =>
            MapEntry(field, values.map((k, v) => MapEntry(k, v.toList()))),
      ),
    };
    await indexFile.writeAsString(jsonEncode(data));
  }

  // Load index from disk
  Future<void> load() async {
    if (!await indexFile.exists()) return;

    final content = await indexFile.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    _keyToOffset.clear();
    _keyToOffset.addAll((data['keyToOffset'] as Map).cast<String, int>());

    _fieldIndexes.clear();
    if (data['fieldIndexes'] != null) {
      final fieldData = data['fieldIndexes'] as Map<String, dynamic>;
      for (final field in fieldData.keys) {
        _fieldIndexes[field] = {};
        final values = fieldData[field] as Map<String, dynamic>;
        for (final value in values.keys) {
          _fieldIndexes[field]![value] = Set<String>.from(values[value]);
        }
      }
    }
  }
}

// ============================================
// 4. DATABASE BOX (Main Interface)
// ============================================

class Box {
  final String name;
  final BinaryStorage _storage;
  final IndexManager _indexManager;
  bool _isOpen = false;

  Box(this.name, String dataPath, String indexPath)
    : _storage = BinaryStorage(dataPath),
      _indexManager = IndexManager(indexPath);

  // Open the box
  Future<void> open() async {
    if (_isOpen) return;

    await _storage.open();
    await _indexManager.load();
    _isOpen = true;
  }

  // Store an object
  Future<void> put(String key, Map<String, dynamic> value) async {
    _ensureOpen();

    // Serialize and write to storage
    final bytes = BinarySerializer.encode(value);
    final offset = await _storage.write(bytes);

    // Update primary index
    _indexManager.addKey(key, offset);

    // Update secondary indexes for all fields
    for (final field in value.keys) {
      _indexManager.indexField(field, value[field], key);
    }

    // Persist index
    await _indexManager.save();
  }

  // Retrieve an object
  Future<Map<String, dynamic>?> get(String key) async {
    _ensureOpen();

    final offset = _indexManager.getOffset(key);
    if (offset == null) return null;

    // Read length header
    final lengthBytes = await _storage.read(offset, 4);
    final buffer = ByteData.sublistView(lengthBytes);
    final length = buffer.getUint32(0, Endian.little);

    // Read full record
    final recordBytes = await _storage.read(offset, 4 + length);
    return BinarySerializer.decode(recordBytes);
  }

  // Delete an object
  Future<void> delete(String key) async {
    _ensureOpen();

    _indexManager.removeKey(key);
    await _indexManager.save();
    // Note: In production, you'd also mark space as deleted for compaction
  }

  // Query by field value
  Future<List<Map<String, dynamic>>> query(String field, dynamic value) async {
    _ensureOpen();

    final keys = _indexManager.queryByField(field, value);
    final results = <Map<String, dynamic>>[];

    for (final key in keys) {
      final obj = await get(key);
      if (obj != null) results.add(obj);
    }

    return results;
  }

  // Get all values
  Future<Map<String, dynamic>> getAll() async {
    _ensureOpen();

    final result = <String, dynamic>{};
    for (final key in _indexManager.getAllKeys()) {
      final value = await get(key);
      if (value != null) result[key] = value;
    }
    return result;
  }

  // Close the box
  Future<void> close() async {
    if (!_isOpen) return;

    await _indexManager.save();
    await _storage.close();
    _isOpen = false;
  }

  // Clear all data
  Future<void> clear() async {
    _ensureOpen();

    await _storage.clear();
    await _indexManager.indexFile.delete();
    await open(); // Reopen with empty state
  }

  void _ensureOpen() {
    if (!_isOpen) {
      throw StateError('Box is not open. Call open() first.');
    }
  }
}

// ============================================
// 5. DATABASE MANAGER
// ============================================

class CustomDB {
  final String basePath;
  final Map<String, Box> _boxes = {};

  CustomDB(this.basePath);

  // Open or create a box
  Future<Box> openBox(String name) async {
    if (_boxes.containsKey(name)) {
      return _boxes[name]!;
    }

    final dataPath = '$basePath/$name.db';
    final indexPath = '$basePath/$name.idx';

    final box = Box(name, dataPath, indexPath);
    await box.open();

    _boxes[name] = box;
    return box;
  }

  // Close a specific box
  Future<void> closeBox(String name) async {
    final box = _boxes[name];
    if (box != null) {
      await box.close();
      _boxes.remove(name);
    }
  }

  // Close all boxes
  Future<void> closeAll() async {
    for (final box in _boxes.values) {
      await box.close();
    }
    _boxes.clear();
  }
}

// ============================================
// 6. USAGE EXAMPLE
// ============================================

void main() async {
  // Initialize database
  final db = CustomDB('./my_database');

  // Open a box (like a table/collection)
  final usersBox = await db.openBox('users');

  // Insert data
  await usersBox.put('user1', {
    'name': 'Alice',
    'age': 30,
    'email': 'alice@example.com',
  });

  await usersBox.put('user2', {
    'name': 'Bob',
    'age': 25,
    'email': 'bob@example.com',
  });

  await usersBox.put('user3', {
    'name': 'Charlie',
    'age': 30,
    'email': 'charlie@example.com',
  });

  // Retrieve by key
  final user = await usersBox.get('user1');
  print('Retrieved: $user');

  // Query by field
  final thirtyYearOlds = await usersBox.query('age', 30);
  print('Users aged 30: $thirtyYearOlds');

  // Get all data
  final allUsers = await usersBox.getAll();
  print('All users: $allUsers');

  // Delete
  await usersBox.delete('user2');

  // Close database
  await db.closeAll();

  print('Database operations completed!');
}
