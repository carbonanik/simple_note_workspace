import 'package:reflectable/reflectable.dart';

class JsonReflector extends Reflectable {
  const JsonReflector()
    : super(
        typeCapability,
        invokingCapability,
        declarationsCapability,
        metadataCapability,
        newInstanceCapability,
      );
}

const jsonReflector = JsonReflector();

class JsonField {
  final String name;
  const JsonField(this.name);
}

Map<String, dynamic> toJson(Object obj) {
  var mirror = jsonReflector.reflect(obj);
  var classMirror = mirror.type;

  final result = <String, dynamic>{};

  classMirror.declarations.forEach((name, decl) {
    if (decl is VariableMirror) {
      var value = mirror.invokeGetter(name);

      if (value == null) {
        result[name] = null;
      } else if (jsonReflector.canReflect(value)) {
        // Nested object → recurse
        result[name] = toJson(value);
      } else if (value is List) {
        // List → check element type
        result[name] = value
            .map((e) => jsonReflector.canReflect(e) ? toJson(e) : e)
            .toList();
      } else {
        // Primitive
        result[name] = value;
      }
    }
  });

  return result;
}

dynamic _fromMapToType(Type type, Map<String, dynamic> map) {
  var classMirror = jsonReflector.reflectType(type) as ClassMirror;

  var defaultConstructor = classMirror.declarations.values
      .whereType<MethodMirror>()
      .firstWhere((m) => m.isConstructor && m.constructorName == "");

  final namedArgs = <Symbol, dynamic>{};

  for (var param in defaultConstructor.parameters) {
    var key = param.simpleName;
    if (!map.containsKey(key)) continue;

    Type? nestedType;
    try {
      nestedType = param.type.reflectedType;
    } catch (_) {}

    var raw = map[key];

    if (nestedType != null && raw is Map) {
      namedArgs[Symbol(key)] = _fromMapToType(
        nestedType,
        raw as Map<String, dynamic>,
      );
    } else {
      namedArgs[Symbol(key)] = raw;
    }
  }
  return classMirror.newInstance("", [], namedArgs);
}

T fromJson<T>(Map<String, dynamic> json) {
  if (!jsonReflector.canReflectType(T)) {
    throw ArgumentError(
      "Type $T is not reflectable — annotate with @jsonReflector",
    );
  }
  return _fromMapToType(T, json) as T;
}

// T fromJson<T>(Map<String, dynamic> json) {
//   var classMirror = jsonReflector.reflectType(T) as ClassMirror;
//   var ctor = classMirror.declarations.values
//       .whereType<MethodMirror>()
//       .firstWhere((m) => m.isConstructor && m.constructorName == "");
//   final namedArgs = <Symbol, dynamic>{};
//   for (var param in ctor.parameters) {
//     var key = param.simpleName;
//     if (json.containsKey(key)) {
//       namedArgs[Symbol(key)] = json[key];
//     }
//   }
//   return classMirror.newInstance("", [], namedArgs) as T;
// }

mixin ReflectableEquality {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    var thisMirror = jsonReflector.reflect(this);
    var otherMirror = jsonReflector.reflect(other);

    for (var decl in thisMirror.type.declarations.values) {
      if (decl is VariableMirror) {
        var field = decl.simpleName;
        var v1 = thisMirror.invokeGetter(field);
        var v2 = otherMirror.invokeGetter(field);
        if (v1 != v2) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    var mirror = jsonReflector.reflect(this);
    int result = 17;

    for (var decl in mirror.type.declarations.values) {
      if (decl is VariableMirror) {
        var value = mirror.invokeGetter(decl.simpleName);
        result = 37 * result + (value?.hashCode ?? 0);
      }
    }
    return result;
  }
}
