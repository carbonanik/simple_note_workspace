import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:simple_json_annotation/simple_json_annotation.dart';
import 'package:simple_json_generator/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';

class JsonGenerator extends GeneratorForAnnotation<JSONGenAnnotation> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = ModelVisitor();
    element.visitChildren(visitor);

    final generator = _CodeGenerator(visitor);
    return generator.generate();
  }
}

class _CodeGenerator {
  final ModelVisitor visitor;
  final StringBuffer _buffer = StringBuffer();

  _CodeGenerator(this.visitor);

  String generate() {
    _writeHeader();
    _writeExtension();
    _writeFromMapFunction();
    return _buffer.toString();
  }

  void _writeHeader() {
    _buffer
      ..writeln('// ignore_for_file: non_constant_identifier_names')
      ..writeln('// ignore_for_file: curly_braces_in_flow_control_structures')
      ..writeln();
  }

  void _writeExtension() {
    final className = visitor.className;
    _buffer.writeln('extension ${className}Extension on $className {');
    _writeToMapMethod();
    _writeCopyWithMethod();
    _buffer.writeln('}');
  }

  void _writeToMapMethod() {
    _buffer
      ..writeln('  Map<String, dynamic> toMap() {')
      ..writeln('    return {');

    for (final entry in _getFieldEntries()) {
      final mapper = _ToMapEntryGenerator(entry.name, entry.type);
      _buffer.writeln('      ${mapper.generate()}');
    }

    _buffer
      ..writeln('    };')
      ..writeln('  }')
      ..writeln();
  }

  void _writeCopyWithMethod() {
    final className = visitor.className;

    _buffer.writeln('  $className copyWith({');
    for (final entry in _getFieldEntries()) {
      _buffer.writeln('    ${entry.typeString}? ${entry.name},');
    }
    _buffer.writeln('  }) {');

    _buffer.writeln('    return $className(');
    for (final entry in _getFieldEntries()) {
      _buffer.writeln(
        '      ${entry.name}: ${entry.name} ?? this.${entry.name},',
      );
    }
    _buffer
      ..writeln('    );')
      ..writeln('  }');
  }

  void _writeFromMapFunction() {
    final className = visitor.className;
    _buffer
      ..writeln()
      ..writeln('$className ${className}FromMap(Map<String, dynamic> map) {')
      ..writeln('  return $className(');

    for (final entry in _getFieldEntries()) {
      final mapper = _FromMapEntryGenerator(
        entry.name,
        entry.type,
        entry.typeString,
      );
      _buffer.writeln('    ${mapper.generate()}');
    }

    _buffer
      ..writeln('  );')
      ..writeln('}');
  }

  List<_FieldEntry> _getFieldEntries() {
    final entries = <_FieldEntry>[];
    for (int i = 0; i < visitor.fields.length; i++) {
      entries.add(
        _FieldEntry(
          name: visitor.fields.keys.elementAt(i),
          type: visitor.fieldTypes.values.elementAt(i),
          typeString: visitor.fields.values.elementAt(i),
        ),
      );
    }
    return entries;
  }
}

/// Represents a field with its metadata
class _FieldEntry {
  final String name;
  final DartType type;
  final String typeString;

  _FieldEntry({
    required this.name,
    required this.type,
    required this.typeString,
  });
}

/// Generates toMap entries for fields
class _ToMapEntryGenerator {
  final String fieldName;
  final DartType fieldType;

  _ToMapEntryGenerator(this.fieldName, this.fieldType);

  String generate() {
    final typeHelper = _TypeHelper(fieldType);

    if (typeHelper.isList) {
      final innerType = typeHelper.listInnerType;
      if (_TypeHelper(innerType).isCustom) {
        return "'$fieldName': $fieldName.map((e) => e.toMap()).toList(),";
      }
      return "'$fieldName': $fieldName,";
    }

    if (typeHelper.isCustom) {
      return "'$fieldName': $fieldName.toMap(),";
    }

    return "'$fieldName': $fieldName,";
  }
}

/// Generates fromMap entries for fields
class _FromMapEntryGenerator {
  final String fieldName;
  final DartType fieldType;
  final String typeString;

  _FromMapEntryGenerator(this.fieldName, this.fieldType, this.typeString);

  String generate() {
    final typeHelper = _TypeHelper(fieldType);
    final buffer = StringBuffer('$fieldName: ');

    if (typeHelper.isList) {
      buffer.write(_generateListParsing(typeHelper));
    } else if (typeHelper.isCustom) {
      buffer.write(_generateCustomTypeParsing());
    } else {
      buffer.write(_generatePrimitiveParsing());
    }

    return buffer.toString();
  }

  String _generateListParsing(_TypeHelper typeHelper) {
    final innerType = typeHelper.listInnerType;
    final innerTypeString = innerType.getDisplayString(withNullability: false);
    final innerTypeHelper = _TypeHelper(innerType);

    return '''(() {
      try {
        final list = map['$fieldName'];
        if (list == null) throw Exception('Field is null');
        if (list is! List) throw Exception('Expected List but got \${list.runtimeType}');
        ${innerTypeHelper.isCustom ? _generateCustomListMapping(innerTypeString) : _generatePrimitiveListMapping(innerTypeString)}
      } catch (e) {
        throw Exception('Error parsing field "$fieldName" of type "$typeString": \$e');
      }
    })(),''';
  }

  String _generateCustomListMapping(String innerTypeString) {
    return '''return list.map((e) {
          try {
            if (e is! Map<String, dynamic>) throw Exception('Expected Map<String, dynamic> but got \${e.runtimeType}');
            return ${innerTypeString}FromMap(e);
          } catch (e) {
            throw Exception('Error parsing list item to $innerTypeString: \$e');
          }
        }).toList();''';
  }

  String _generatePrimitiveListMapping(String innerTypeString) {
    return '''return List<$innerTypeString>.from(list.map((e) {
          if (e is! $innerTypeString) throw Exception('Expected $innerTypeString but got \${e.runtimeType}');
          return e;
        }));''';
  }

  String _generateCustomTypeParsing() {
    final cleanType = typeString.replaceFirst('*', '');
    return '''(() {
      try {
        final value = map['$fieldName'];
        if (value == null) throw Exception('Field is null');
        if (value is! Map<String, dynamic>) throw Exception('Expected Map<String, dynamic> but got \${value.runtimeType}');
        return ${cleanType}FromMap(value);
      } catch (e) {
        throw Exception('Error parsing field "$fieldName" of type "$typeString": \$e');
      }
    })(),''';
  }

  String _generatePrimitiveParsing() {
    return '''(() {
      try {
        final value = map['$fieldName'];
        if (value == null) throw Exception('Field is null');
        if (value is! $typeString) throw Exception('Expected $typeString but got \${value.runtimeType}');
        return value;
      } catch (e) {
        throw Exception('Error parsing field "$fieldName" of type "$typeString": \$e');
      }
    })(),''';
  }
}

class _TypeHelper {
  final DartType type;

  _TypeHelper(this.type);

  bool get isList => type.isDartCoreList;

  bool get isCustom {
    final typeStr = type.getDisplayString(withNullability: false);
    return !_isPrimitive(typeStr);
  }

  bool get isEnum => type.isDartCoreEnum;

  DartType get listInnerType {
    if (type is ParameterizedType) {
      final paramType = type as ParameterizedType;
      if (paramType.typeArguments.isNotEmpty) {
        return paramType.typeArguments.first;
      }
    }
    return type;
  }

  static bool _isPrimitive(String type) {
    const primitives = {
      'int',
      'double',
      'String',
      'bool',
      'num',
      'dynamic',
      'Object',
    };
    return primitives.contains(type);
  }
}
