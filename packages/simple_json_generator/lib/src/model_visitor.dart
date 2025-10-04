import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor2.dart';

class ModelVisitor extends SimpleElementVisitor2<void> {
  String className = '';
  Map<String, String> fields = {};
  Map<String, DartType> fieldTypes = {};

  @override
  void visitConstructorElement(ConstructorElement element) {
    final returnType = element.returnType.toString();
    className = returnType.replaceFirst('*', '');
  }

  @override
  void visitFieldElement(FieldElement element) {
    // ignore: deprecated_member_use
    final typeString = element.type.getDisplayString(withNullability: false);
    fields[element.name!] = typeString;
    fieldTypes[element.name!] = element.type;
  }
}
