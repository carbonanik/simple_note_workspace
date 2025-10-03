import 'dart:io';

/// Custom JSON code generator for Flutter models
/// Creates toJson and fromJson methods automatically
class JsonCodeGenerator {
  /// Generates toJson and fromJson methods for a class
  static String generateJsonMethods({
    required String className,
    required List<Field> fields,
  }) {
    final fromJsonMethod = _generateFromJson(className, fields);
    final toJsonMethod = _generateToJson(fields);

    return '''
// Generated code - do not modify by hand

  /// Creates a [$className] instance from JSON map
  factory $className.fromJson(Map<String, dynamic> json) {
    return $className(
$fromJsonMethod
    );
  }

  /// Converts this [$className] instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
$toJsonMethod
    };
  }
''';
  }

  static String _generateFromJson(String className, List<Field> fields) {
    return fields
        .map((field) {
          final jsonKey = field.jsonKey ?? field.name;
          return '      ${field.name}: ${_parseFromJson(field, jsonKey)},';
        })
        .join('\n');
  }

  static String _parseFromJson(Field field, String jsonKey) {
    final isNullable = field.isNullable;
    final type = field.type;

    if (type == 'String' ||
        type == 'int' ||
        type == 'double' ||
        type == 'bool') {
      return isNullable
          ? "json['$jsonKey'] as $type?"
          : "json['$jsonKey'] as $type";
    } else if (type == 'DateTime') {
      return isNullable
          ? "json['$jsonKey'] != null ? DateTime.parse(json['$jsonKey'] as String) : null"
          : "DateTime.parse(json['$jsonKey'] as String)";
    } else if (type.startsWith('List<')) {
      final innerType = type.substring(5, type.length - 1);
      if (_isPrimitive(innerType)) {
        return isNullable
            ? "(json['$jsonKey'] as List<dynamic>?)?.map((e) => e as $innerType).toList()"
            : "(json['$jsonKey'] as List<dynamic>).map((e) => e as $innerType).toList()";
      } else {
        return isNullable
            ? "(json['$jsonKey'] as List<dynamic>?)?.map((e) => $innerType.fromJson(e as Map<String, dynamic>)).toList()"
            : "(json['$jsonKey'] as List<dynamic>).map((e) => $innerType.fromJson(e as Map<String, dynamic>)).toList()";
      }
    } else if (type.startsWith('Map<')) {
      return isNullable
          ? "json['$jsonKey'] as Map<String, dynamic>?"
          : "json['$jsonKey'] as Map<String, dynamic>";
    } else {
      // Custom object
      return isNullable
          ? "json['$jsonKey'] != null ? $type.fromJson(json['$jsonKey'] as Map<String, dynamic>) : null"
          : "$type.fromJson(json['$jsonKey'] as Map<String, dynamic>)";
    }
  }

  static String _generateToJson(List<Field> fields) {
    return fields
        .map((field) {
          final jsonKey = field.jsonKey ?? field.name;
          return "      '$jsonKey': ${_parseToJson(field)},";
        })
        .join('\n');
  }

  static String _parseToJson(Field field) {
    final type = field.type;

    if (type == 'String' ||
        type == 'int' ||
        type == 'double' ||
        type == 'bool') {
      return field.name;
    } else if (type == 'DateTime') {
      return field.isNullable
          ? '${field.name}?.toIso8601String()'
          : '${field.name}.toIso8601String()';
    } else if (type.startsWith('List<')) {
      final innerType = type.substring(5, type.length - 1);
      if (_isPrimitive(innerType)) {
        return field.name;
      } else {
        return field.isNullable
            ? '${field.name}?.map((e) => e.toJson()).toList()'
            : '${field.name}.map((e) => e.toJson()).toList()';
      }
    } else if (type.startsWith('Map<')) {
      return field.name;
    } else {
      // Custom object
      return field.isNullable
          ? '${field.name}?.toJson()'
          : '${field.name}.toJson()';
    }
  }

  static bool _isPrimitive(String type) {
    return ['String', 'int', 'double', 'bool', 'num'].contains(type);
  }

  /// Generates a complete model file with JSON methods
  static String generateCompleteModel({
    required String className,
    required List<Field> fields,
    String? description,
  }) {
    final constructor = _generateConstructor(className, fields);
    final fieldDeclarations = fields
        .map((f) => '  final ${f.type}${f.isNullable ? '?' : ''} ${f.name};')
        .join('\n');
    final jsonMethods = generateJsonMethods(
      className: className,
      fields: fields,
    );
    final copyWith = _generateCopyWith(className, fields);

    return '''
${description != null ? '/// $description\n' : ''}class $className {
$fieldDeclarations

$constructor

$jsonMethods

$copyWith
}
''';
  }

  static String _generateConstructor(String className, List<Field> fields) {
    final params = fields
        .map((f) {
          final required = !f.isNullable ? 'required ' : '';
          return '    ${required}this.${f.name},';
        })
        .join('\n');

    return '''  $className({
$params
  });''';
  }

  static String _generateCopyWith(String className, List<Field> fields) {
    final params = fields
        .map((f) {
          return '    ${f.type}${f.isNullable ? '?' : ''}? ${f.name},';
        })
        .join('\n');

    final assignments = fields
        .map((f) {
          return '      ${f.name}: ${f.name} ?? this.${f.name},';
        })
        .join('\n');

    return '''  /// Creates a copy of this [$className] with the given fields replaced
  $className copyWith({
$params
  }) {
    return $className(
$assignments
    );
  }''';
  }
}

/// Represents a field in a class
class Field {
  final String name;
  final String type;
  final bool isNullable;
  final String? jsonKey; // For mapping different JSON key names

  Field({
    required this.name,
    required this.type,
    this.isNullable = false,
    this.jsonKey,
  });
}

// Example usage
void main() {
  // Define your model fields
  final fields = [
    Field(name: 'id', type: 'int'),
    Field(name: 'name', type: 'String'),
    Field(name: 'email', type: 'String'),
    Field(name: 'age', type: 'int', isNullable: true),
    Field(
      name: 'phoneNumber',
      type: 'String',
      isNullable: true,
      jsonKey: 'phone_number',
    ),
    Field(name: 'isActive', type: 'bool'),
    Field(name: 'createdAt', type: 'DateTime'),
    Field(name: 'tags', type: 'List<String>', isNullable: true),
  ];

  // Generate the complete model
  final generatedCode = JsonCodeGenerator.generateCompleteModel(
    className: 'User',
    fields: fields,
    description: 'User model with auto-generated JSON serialization',
  );

  // Print or save to file
  print(generatedCode);

  // Optional: Save to file
  final file = File('lib/models/user.dart');
  file.createSync(recursive: true);
  file.writeAsStringSync(generatedCode);
  print('\n✅ Model generated successfully at: ${file.path}');
}
