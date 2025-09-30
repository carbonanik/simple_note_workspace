// ============================ JsonParser ============================

/// A comprehensive utility class for safe JSON parsing with detailed error messages
/// Usage: final parser = JsonParser(json, 'ClassName');
class JsonParser {
  final Map<String, dynamic> _json;
  final String _className;

  JsonParser(this._json, this._className);

  /// Factory constructor for cleaner syntax
  factory JsonParser.of(Map<String, dynamic> json, String className) {
    return JsonParser(json, className);
  }

  // ==================== STRING PARSING ====================

  /// Parse required String field
  String getString(String key) {
    return _parseField<String>(
      key: key,
      parser: () => _json[key] as String,
      expectedType: 'String',
      isRequired: true,
    );
  }

  /// Parse optional String field
  String? getStringOrNull(String key) {
    if (!_json.containsKey(key) || _json[key] == null) return null;
    return _parseField<String>(
      key: key,
      parser: () => _json[key] as String,
      expectedType: 'String',
      isRequired: false,
    );
  }

  /// Parse String with default value
  String getStringWithDefault(String key, String defaultValue) {
    if (!_json.containsKey(key) || _json[key] == null) return defaultValue;
    return getString(key);
  }

  // ==================== INT PARSING ====================

  /// Parse required int field (handles String to int conversion)
  int getInt(String key) {
    return _parseField<int>(
      key: key,
      parser: () {
        final value = _json[key];
        if (value is int) return value;
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed == null)
            throw FormatException('Cannot parse "$value" to int');
          return parsed;
        }
        if (value is double) return value.toInt();
        throw TypeError();
      },
      expectedType: 'int',
      isRequired: true,
    );
  }

  /// Parse optional int field
  int? getIntOrNull(String key) {
    if (!_json.containsKey(key) || _json[key] == null) return null;
    return getInt(key);
  }

  /// Parse int with default value
  int getIntWithDefault(String key, int defaultValue) {
    if (!_json.containsKey(key) || _json[key] == null) return defaultValue;
    return getInt(key);
  }

  // ==================== DOUBLE PARSING ====================

  /// Parse required double field (handles String/int to double conversion)
  double getDouble(String key) {
    return _parseField<double>(
      key: key,
      parser: () {
        final value = _json[key];
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed == null)
            throw FormatException('Cannot parse "$value" to double');
          return parsed;
        }
        throw TypeError();
      },
      expectedType: 'double',
      isRequired: true,
    );
  }

  /// Parse optional double field
  double? getDoubleOrNull(String key) {
    if (!_json.containsKey(key) || _json[key] == null) return null;
    return getDouble(key);
  }

  /// Parse double with default value
  double getDoubleWithDefault(String key, double defaultValue) {
    if (!_json.containsKey(key) || _json[key] == null) return defaultValue;
    return getDouble(key);
  }

  // ==================== BOOL PARSING ====================

  /// Parse required bool field (handles 0/1 and "true"/"false" strings)
  bool getBool(String key) {
    return _parseField<bool>(
      key: key,
      parser: () {
        final value = _json[key];
        if (value is bool) return value;
        if (value is int) return value == 1;
        if (value is String) {
          final lower = value.toLowerCase();
          if (lower == 'true' || lower == '1') return true;
          if (lower == 'false' || lower == '0') return false;
          throw FormatException('Cannot parse "$value" to bool');
        }
        throw TypeError();
      },
      expectedType: 'bool',
      isRequired: true,
    );
  }

  /// Parse optional bool field
  bool? getBoolOrNull(String key) {
    if (!_json.containsKey(key) || _json[key] == null) return null;
    return getBool(key);
  }

  /// Parse bool with default value
  bool getBoolWithDefault(String key, bool defaultValue) {
    if (!_json.containsKey(key) || _json[key] == null) return defaultValue;
    return getBool(key);
  }

  // ==================== DATETIME PARSING ====================

  /// Parse required DateTime field (ISO 8601 format)
  DateTime getDateTime(String key) {
    return _parseField<DateTime>(
      key: key,
      parser: () {
        final value = _json[key];
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            throw FormatException('Invalid DateTime format: $value');
          }
        }
        if (value is int) {
          // Assume Unix timestamp in milliseconds
          return DateTime.fromMillisecondsSinceEpoch(value);
        }
        throw TypeError();
      },
      expectedType: 'DateTime',
      isRequired: true,
    );
  }

  /// Parse optional DateTime field
  DateTime? getDateTimeOrNull(String key) {
    if (!_json.containsKey(key) || _json[key] == null) return null;
    return getDateTime(key);
  }

  // ==================== LIST PARSING ====================

  /// Parse required List field
  List<T> getList<T>(String key, T Function(dynamic) fromJson) {
    try {
      if (!_json.containsKey(key)) {
        throw FormatException(
          '[$_className] Missing required list field "$key"',
        );
      }

      if (_json[key] == null) {
        throw FormatException(
          '[$_className] List field "$key" is null but required',
        );
      }

      final list = _json[key] as List;
      return list.map((item) {
        try {
          return fromJson(item);
        } catch (e) {
          throw FormatException(
            '[$_className] Error parsing item in list "$key": $e\nItem: $item',
          );
        }
      }).toList();
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException(
        '[$_className] Error parsing list "$key": $e\n'
        'Actual type: ${_json[key]?.runtimeType}\n'
        'Value: ${_json[key]}',
      );
    }
  }

  /// Parse optional List field
  List<T>? getListOrNull<T>(String key, T Function(dynamic) fromJson) {
    if (!_json.containsKey(key) || _json[key] == null) return null;
    return getList<T>(key, fromJson);
  }

  /// Parse List with default value
  List<T> getListWithDefault<T>(
    String key,
    T Function(dynamic) fromJson,
    List<T> defaultValue,
  ) {
    if (!_json.containsKey(key) || _json[key] == null) return defaultValue;
    return getList<T>(key, fromJson);
  }

  // ==================== OBJECT PARSING ====================

  /// Parse required nested object
  T getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      if (!_json.containsKey(key)) {
        throw FormatException(
          '[$_className] Missing required object field "$key"',
        );
      }

      if (_json[key] == null) {
        throw FormatException(
          '[$_className] Object field "$key" is null but required',
        );
      }

      return fromJson(_json[key] as Map<String, dynamic>);
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException(
        '[$_className] Error parsing object "$key": $e\n'
        'Actual type: ${_json[key]?.runtimeType}\n'
        'Value: ${_json[key]}',
      );
    }
  }

  /// Parse optional nested object
  T? getObjectOrNull<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    if (!_json.containsKey(key) || _json[key] == null) return null;
    return getObject<T>(key, fromJson);
  }

  // ==================== MAP PARSING ====================

  /// Parse Map field
  Map<String, dynamic> getMap(String key) {
    return _parseField<Map<String, dynamic>>(
      key: key,
      parser: () => Map<String, dynamic>.from(_json[key] as Map),
      expectedType: 'Map<String, dynamic>',
      isRequired: true,
    );
  }

  /// Parse optional Map field
  Map<String, dynamic>? getMapOrNull(String key) {
    if (!_json.containsKey(key) || _json[key] == null) return null;
    return getMap(key);
  }

  // ==================== ENUM PARSING ====================

  /// Parse enum from string
  T getEnum<T>(String key, List<T> values, String Function(T) enumToString) {
    final stringValue = getString(key);
    try {
      return values.firstWhere(
        (e) => enumToString(e) == stringValue,
        orElse: () => throw FormatException(
          'Invalid enum value: $stringValue. Expected one of: ${values.map(enumToString).join(", ")}',
        ),
      );
    } catch (e) {
      throw FormatException('[$_className] Error parsing enum "$key": $e');
    }
  }

  /// Parse optional enum from string
  T? getEnumOrNull<T>(
    String key,
    List<T> values,
    String Function(T) enumToString,
  ) {
    if (!_json.containsKey(key) || _json[key] == null) return null;
    return getEnum<T>(key, values, enumToString);
  }

  // ==================== CORE PARSING LOGIC ====================

  /// Core parsing logic with detailed error messages
  T _parseField<T>({
    required String key,
    required T Function() parser,
    required String expectedType,
    required bool isRequired,
  }) {
    try {
      // Check if key exists
      if (!_json.containsKey(key)) {
        if (isRequired) {
          throw FormatException('[$_className] Missing required field "$key"');
        }
        throw Exception('Field not found');
      }

      // Check if value is null
      if (_json[key] == null) {
        if (isRequired) {
          throw FormatException(
            '[$_className] Field "$key" is null but required',
          );
        }
        throw Exception('Value is null');
      }

      // Parse the value
      return parser();
    } catch (e) {
      if (e is FormatException) rethrow;

      throw FormatException(
        '[$_className] Error parsing field "$key":\n'
        '  Expected type: $expectedType\n'
        '  Actual type: ${_json[key]?.runtimeType}\n'
        '  Actual value: ${_json[key]}\n'
        '  Error: $e',
      );
    }
  }

  /// Get the raw JSON map
  Map<String, dynamic> get rawJson => _json;

  /// Check if a key exists
  bool hasKey(String key) => _json.containsKey(key);

  /// Check if a key exists and is not null
  bool hasNonNullKey(String key) =>
      _json.containsKey(key) && _json[key] != null;
}

/// Extension to make JSON parsing easier
extension JsonParserExtension on Map<String, dynamic> {
  JsonParser parser(String className) => JsonParser(this, className);
}

class User {
  final String id;
  final String name;
  final int age;
  final String? email;
  final bool isActive;
  final DateTime createdAt;
  final Address address;
  final List<String> hobbies;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.age,
    this.email,
    required this.isActive,
    required this.createdAt,
    required this.address,
    required this.hobbies,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final parser = JsonParser(json, 'User');

    return User(
      id: parser.getString('id'),
      name: parser.getString('name'),
      age: parser.getInt('age'),
      email: parser.getStringOrNull('email'),
      isActive: parser.getBool('is_active'),
      createdAt: parser.getDateTime('created_at'),
      address: parser.getObject('address', Address.fromJson),
      hobbies: parser.getList('hobbies', (item) => item as String),
      role: parser.getEnum(
        'role',
        UserRole.values,
        (e) => e.toString().split('.').last,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'email': email,
    'is_active': isActive,
    'created_at': createdAt.toIso8601String(),
    'address': address.toJson(),
    'hobbies': hobbies,
    'role': role.toString().split('.').last,
  };
}

enum UserRole { admin, user, guest }

// lib/models/address.dart
class Address {
  final String street;
  final String city;
  final String zipCode;
  final String? country;

  Address({
    required this.street,
    required this.city,
    required this.zipCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    final parser = JsonParser(json, 'Address');

    return Address(
      street: parser.getString('street'),
      city: parser.getString('city'),
      zipCode: parser.getString('zip_code'),
      country: parser.getStringOrNull('country'),
    );
  }

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'zip_code': zipCode,
    'country': country,
  };
}

// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final double price;
  final int stock;
  final List<String> images;
  final Category? category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.images,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final parser = JsonParser(json, 'Product');

    return Product(
      id: parser.getInt('id'),
      name: parser.getString('name'),
      price: parser.getDouble('price'),
      stock: parser.getIntWithDefault('stock', 0),
      images: parser.getListWithDefault('images', (item) => item as String, []),
      category: parser.getObjectOrNull('category', Category.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'stock': stock,
    'images': images,
    'category': category?.toJson(),
  };
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    final parser = JsonParser(json, 'Category');
    return Category(id: parser.getInt('id'), name: parser.getString('name'));
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
