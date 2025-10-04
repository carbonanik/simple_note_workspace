class DI {
  static final DI _instance = DI._internal();
  factory DI() => _instance;
  DI._internal();

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
    print("Has disposer ${_disposers.containsKey(mapKey)}");
  }

  void unregister<T>({String? key}) {
    reset<T>(key: key);
    final mapKey = (key, T);
    _factories.remove(mapKey);
    _disposers.remove(mapKey);
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
