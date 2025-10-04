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

    final buffer = StringBuffer();
    String className = '${visitor.className}Gen';

    // CLASS DECLARATION
    buffer.writeln('class $className {');

    // FIELDS
    for (int i = 0; i < visitor.fields.length; i++) {
      buffer.writeln(
        'final ${visitor.fields.values.elementAt(i)} ${visitor.fields.keys.elementAt(i)};',
      );
    }

    // CONSTRUCTOR
    buffer.writeln('const $className({');
    for (int i = 0; i < visitor.fields.length; i++) {
      buffer.writeln('required this.${visitor.fields.keys.elementAt(i)},');
    }
    buffer.writeln('});');

    // TO MAP
    buffer.writeln('Map<String, dynamic> toMap() {');
    buffer.writeln('return {');
    for (int i = 0; i < visitor.fields.length; i++) {
      final fieldName = visitor.fields.keys.elementAt(i);
      final fieldType = visitor.fieldTypes.values.elementAt(i);
      buffer.writeln(_generateToMapEntry(fieldName, fieldType));
    }
    buffer.writeln('};');
    buffer.writeln('}');

    // FROM MAP
    buffer.writeln('factory $className.fromMap(Map<String, dynamic> map) {');
    buffer.writeln('return $className(');
    for (int i = 0; i < visitor.fields.length; i++) {
      final fieldName = visitor.fields.keys.elementAt(i);
      final fieldType = visitor.fieldTypes.values.elementAt(i);
      final typeString = visitor.fields.values.elementAt(i);
      buffer.writeln(_generateFromMapEntry(fieldName, fieldType, typeString));
    }
    buffer.writeln(');');
    buffer.writeln('}');

    // copyWith
    buffer.writeln('$className copyWith({');
    for (int i = 0; i < visitor.fields.length; i++) {
      buffer.writeln(
        '${visitor.fields.values.elementAt(i)}? ${visitor.fields.keys.elementAt(i)},',
      );
    }
    buffer.writeln('}) {');
    buffer.writeln('return $className(');
    for (int i = 0; i < visitor.fields.length; i++) {
      buffer.writeln(
        "${visitor.fields.keys.elementAt(i)}: ${visitor.fields.keys.elementAt(i)} ?? this.${visitor.fields.keys.elementAt(i)},",
      );
    }
    buffer.writeln(');');
    buffer.writeln('}');

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateToMapEntry(String fieldName, DartType fieldType) {
    if (_isListType(fieldType)) {
      final innerType = _getListInnerType(fieldType);
      if (_isCustomType(innerType)) {
        return "'$fieldName': $fieldName.map((e) => e.toMap()).toList(),";
      }
      return "'$fieldName': $fieldName,";
    } else if (_isCustomType(fieldType)) {
      return "'$fieldName': $fieldName.toMap(),";
    }
    return "'$fieldName': $fieldName,";
  }

  String _generateFromMapEntry(
    String fieldName,
    DartType fieldType,
    String typeString,
  ) {
    final buffer = StringBuffer();
    buffer.write("$fieldName: ");

    if (_isListType(fieldType)) {
      final innerType = _getListInnerType(fieldType);
      final innerTypeString = innerType.getDisplayString(
        withNullability: false,
      );

      buffer.write("(() {\n");
      buffer.write("  try {\n");
      buffer.write("    final list = map['$fieldName'];\n");
      buffer.write("    if (list == null) throw Exception('Field is null');\n");
      buffer.write(
        "    if (list is! List) throw Exception('Expected List but got \${list.runtimeType}');\n",
      );

      if (_isCustomType(innerType)) {
        buffer.write("    return list.map((e) {\n");
        buffer.write("      try {\n");
        buffer.write(
          "        if (e is! Map<String, dynamic>) throw Exception('Expected Map<String, dynamic> but got \${e.runtimeType}');\n",
        );
        buffer.write("        return ${innerTypeString}Gen.fromMap(e);\n");
        buffer.write("      } catch (e) {\n");
        buffer.write(
          "        throw Exception('Error parsing list item to $innerTypeString: \$e');\n",
        );
        buffer.write("      }\n");
        buffer.write("    }).toList();\n");
      } else {
        buffer.write("    return List<$innerTypeString>.from(list.map((e) {\n");
        buffer.write(
          "      if (e is! $innerTypeString) throw Exception('Expected $innerTypeString but got \${e.runtimeType}');\n",
        );
        buffer.write("      return e;\n");
        buffer.write("    }));\n");
      }

      buffer.write("  } catch (e) {\n");
      buffer.write(
        "    throw Exception('Error parsing field \"$fieldName\" of type \"$typeString\": \$e');\n",
      );
      buffer.write("  }\n");
      buffer.write("})(),");
    } else if (_isCustomType(fieldType)) {
      final cleanType = typeString.replaceFirst('*', '');
      buffer.write("(() {\n");
      buffer.write("  try {\n");
      buffer.write("    final value = map['$fieldName'];\n");
      buffer.write(
        "    if (value == null) throw Exception('Field is null');\n",
      );
      buffer.write(
        "    if (value is! Map<String, dynamic>) throw Exception('Expected Map<String, dynamic> but got \${value.runtimeType}');\n",
      );
      buffer.write("    return ${cleanType}Gen.fromMap(value);\n");
      buffer.write("  } catch (e) {\n");
      buffer.write(
        "    throw Exception('Error parsing field \"$fieldName\" of type \"$typeString\": \$e');\n",
      );
      buffer.write("  }\n");
      buffer.write("})(),");
    } else {
      buffer.write("(() {\n");
      buffer.write("  try {\n");
      buffer.write("    final value = map['$fieldName'];\n");
      buffer.write(
        "    if (value == null) throw Exception('Field is null');\n",
      );
      buffer.write(
        "    if (value is! $typeString) throw Exception('Expected $typeString but got \${value.runtimeType}');\n",
      );
      buffer.write("    return value;\n");
      buffer.write("  } catch (e) {\n");
      buffer.write(
        "    throw Exception('Error parsing field \"$fieldName\" of type \"$typeString\": \$e');\n",
      );
      buffer.write("  }\n");
      buffer.write("})(),");
    }

    return buffer.toString();
  }

  bool _isListType(DartType type) {
    return type.isDartCoreList;
  }

  DartType _getListInnerType(DartType listType) {
    if (listType is ParameterizedType && listType.typeArguments.isNotEmpty) {
      return listType.typeArguments.first;
    }
    return listType;
  }

  bool _isCustomType(DartType type) {
    final typeStr = type.getDisplayString(withNullability: false);
    return !_isPrimitiveType(typeStr);
  }

  bool _isPrimitiveType(String type) {
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
