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
  final String? jsonKey;
  final bool? isList;
  final Type? type;
  const JsonField({this.jsonKey, this.isList, this.type});
}

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
          key = meta.jsonKey ?? name;
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

dynamic _fromMapToType(Type type, Map<String, dynamic> map, String callKey) {
  print('call _fromMapToType type: $type callKey: $callKey');
  var classMirror = jsonReflector.reflectType(type) as ClassMirror;

  var defaultConstructor = classMirror.declarations.values
      .whereType<MethodMirror>()
      .firstWhere((m) => m.isConstructor && m.constructorName == "");

  final namedArgs = <Symbol, dynamic>{};

  for (var param in defaultConstructor.parameters) {
    var key = param.simpleName;

    var jsonKey = param.simpleName;
    JsonField? fieldMetaData;
    for (var meta in classMirror.declarations[key]?.metadata ?? []) {
      if (meta is JsonField) {
        jsonKey = meta.jsonKey ?? key;
        fieldMetaData = meta;
      }
    }

    print("type: $type, key: $key");
    if (!map.containsKey(jsonKey)) continue;

    Type? nestedType;
    try {
      nestedType = param.type.reflectedType;
    } catch (_) {}

    var raw = map[jsonKey];

    if (nestedType != null && raw is Map) {
      namedArgs[Symbol(key)] = _fromMapToType(
        nestedType,
        raw as Map<String, dynamic>,
        'from nested type',
      );
    } else if (fieldMetaData?.isList == true && raw is List) {
      final listItemType = fieldMetaData!.type!;

      final items = <dynamic>[];
      for (var r in raw) {
        final listItemInstance = _fromMapToType(
          listItemType,
          r as Map<String, dynamic>,
          'from list item',
        );
        items.add(listItemInstance);
      }

      namedArgs[Symbol(key)] = items;
    } else {
      namedArgs[Symbol(key)] = raw;
    }
  }
  // print(namedArgs);
  return classMirror.newInstance("", [], namedArgs);
}

T fromJson<T>(Map<String, dynamic> json) {
  if (!jsonReflector.canReflectType(T)) {
    throw ArgumentError(
      "Type $T is not reflectable — annotate with @jsonReflector",
    );
  }
  return _fromMapToType(T, json, 'from fromJson') as T;
}

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
