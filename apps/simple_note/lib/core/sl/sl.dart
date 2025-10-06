class SL {
  static final SL _instance = SL._internal();
  factory SL() => _instance;
  SL._internal();

  final Map<(String?, Type), Function> _factories = {};
  final Map<(String?, Type), Function> _disposers = {};
  final Map<(String?, Type), Object> _instances = {};

  T? register<T>(
    T Function() factory, {
    String? key,
    void Function(T instance)? onDispose,
    bool isLazy = false,
  }) {
    final mapKey = (key, T);
    _factories[mapKey] = factory;
    if (onDispose != null) {
      _disposers[mapKey] = onDispose;
    }
    if (!isLazy) {
      _instances[mapKey] = factory() as Object;
      return _instances[mapKey] as T;
    }
    return null;
  }

  T? registerLazy<T>(
    T Function() factory, {
    String? key,
    void Function(T instance)? onDispose,
  }) {
    return register<T>(factory, key: key, onDispose: onDispose, isLazy: true);
  }

  T get<T>({String? key}) {
    final mapKey = (key, T);

    if (_instances.containsKey(mapKey)) {
      return _instances[mapKey] as T;
    }
    if (_factories.containsKey(mapKey)) {
      final instance = _factories[mapKey]!() as T;
      _instances[mapKey] = instance as Object;
      return instance;
    }
    throw Exception('No factory found for type $T');
  }

  T getWithKey<T>(String key) {
    final mapKey = (key, T);

    if (_instances.containsKey(mapKey)) {
      return _instances[mapKey] as T;
    }

    if (_factories.containsKey(mapKey)) {
      final instance = _factories[mapKey]!() as T;
      _instances[mapKey] = instance as Object;
      return instance;
    }

    final defaultMapKey = (null, T);
    if (_factories.containsKey(defaultMapKey)) {
      final instance = _factories[defaultMapKey]!() as T;
      _instances[mapKey] = instance as Object;

      _factories[mapKey] = _factories[defaultMapKey]!;

      if (_disposers.containsKey(defaultMapKey)) {
        _disposers[mapKey] = _disposers[defaultMapKey]!;
      }

      return instance;
    }

    throw Exception('No factory found for type $T');
  }

  T? tryGet<T>({String? key}) {
    try {
      return get<T>(key: key);
    } catch (e) {
      return null;
    }
  }

  void reset<T>({String? key}) {
    final mapKey = (key, T);
    if (_instances.containsKey(mapKey)) {
      if (_disposers.containsKey(mapKey)) {
        _disposers[mapKey]?.call(_instances[mapKey]!);
      }
      _instances.remove(mapKey);
    }
  }

  // TODO: reset all keyed instances of the same type
  void resetAll<T>() {
    throw UnimplementedError();
  }

  void unregister<T>({String? key}) {
    reset<T>(key: key);
    final mapKey = (key, T);
    _factories.remove(mapKey);
    _disposers.remove(mapKey);
  }

  // TODO: unregister all keyed instances of the same type
  void unregisterAll<T>() {
    throw UnimplementedError();
  }

  bool isRegistered<T>({String? key}) {
    final mapKey = (key, T);
    return _instances.containsKey(mapKey) || _factories.containsKey(mapKey);
  }

  void dispose() {
    _disposers.forEach((key, disposer) => disposer(_instances[key]!));
    _instances.clear();
    _factories.clear();
  }
}
