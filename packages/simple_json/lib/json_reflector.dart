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

// ==================== TO JSON ====================

Map<String, dynamic> toJson(Object obj) {
  var mirror = jsonReflector.reflect(obj);
  var classMirror = mirror.type;

  final result = <String, dynamic>{};

  classMirror.declarations.forEach((name, decl) {
    if (decl is VariableMirror) {
      var key = name;
      var value = mirror.invokeGetter(name);

      for (var meta in decl.metadata) {
        if (meta is JsonField) {
          key = meta.name;
        }
      }

      if (value == null) {
        result[key] = null;
      } else if (jsonReflector.canReflect(value)) {
        result[key] = toJson(value);
      } else if (value is List) {
        result[key] = value
            .map((e) => jsonReflector.canReflect(e) ? toJson(e) : e)
            .toList();
      } else {
        result[key] = value;
      }
    }
  });

  return result;
}

// ==================== FROM JSON ====================

MethodMirror _getDefaultConstructor(ClassMirror classMirror) {
  return classMirror.declarations.values.whereType<MethodMirror>().firstWhere(
    (m) => m.isConstructor && m.constructorName == "",
  );
}

Type? _tryGetParamType(ParameterMirror param) {
  try {
    return param.type.reflectedType;
  } catch (_) {
    return null;
  }
}

String? _findJsonFieldKeyInMetadata(List<Object> metadata) {
  for (var meta in metadata) {
    if (meta is JsonField) {
      return meta.name;
    }
  }
  return null;
}

Map<Symbol, dynamic> _generateNamedArgsForDefaultConstructor(
  ClassMirror classMirror,
  MethodMirror defaultConstructor,
  Map<String, dynamic> map,
) {
  final namedArgs = <Symbol, dynamic>{};
  for (var param in defaultConstructor.parameters) {
    var arg = _generateSingleArg(classMirror, param, map);
    if (arg != null) {
      namedArgs[arg.key] = arg.value;
    }
  }

  return namedArgs;
}

MapEntry? _generateSingleArg(
  ClassMirror classMirror,
  ParameterMirror param,
  Map<String, dynamic> map,
) {
  // keys
  var key = param.simpleName;

  var jsonKey = _findJsonFieldKeyInMetadata(
    classMirror.declarations[key]?.metadata ?? [],
  );
  jsonKey ??= key;

  // early return
  if (!map.containsKey(jsonKey)) return null;

  Type? nestedType = _tryGetParamType(param);
  var raw = map[jsonKey];

  // var listMirror = jsonReflector.reflectType(List) as ClassMirror;
  // var isList = param.type.isSubtypeOf(listMirror);
  print(param.owner);

  // making map entry
  MapEntry mapEntry;
  if (nestedType != null && raw is Map) {
    var objIns = _fromMapToType(nestedType, raw as Map<String, dynamic>);
    mapEntry = MapEntry(Symbol(key), objIns);
  } else {
    mapEntry = MapEntry(Symbol(key), raw);
  }

  return mapEntry;
}

dynamic _fromMapToType(Type type, Map<String, dynamic> map) {
  var classMirror = jsonReflector.reflectType(type) as ClassMirror;

  var defaultConstructor = _getDefaultConstructor(classMirror);

  final namedArgs = _generateNamedArgsForDefaultConstructor(
    classMirror,
    defaultConstructor,
    map,
  );

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

// ==================== EQUALITY ====================

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
