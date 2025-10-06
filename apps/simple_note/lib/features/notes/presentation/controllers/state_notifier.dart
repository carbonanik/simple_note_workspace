import 'package:flutter/material.dart';

enum AsyncStatus { initial, loading, success, error }

class AsyncData<T> {
  final T? value;
  final AsyncStatus status;
  final Object? error;

  /// assert when status is success value can't be null
  const AsyncData._({
    this.value,
    this.status = AsyncStatus.initial,
    this.error,
  });

  bool get isInitial => status == AsyncStatus.initial;
  bool get isLoading => status == AsyncStatus.loading;
  bool get hasError => status == AsyncStatus.error;
  bool get isSuccess => status == AsyncStatus.success;

  bool get isEmpty => value == null;

  R when<R>({
    required R Function(T? value) initial,
    required R Function(T? value) loading,
    required R Function(T value) success,
    required R Function(T? value, Object error) error,
  }) {
    switch (status) {
      case AsyncStatus.initial:
        return initial(value);
      case AsyncStatus.loading:
        return loading(value);
      case AsyncStatus.success:
        return success(value as T);
      case AsyncStatus.error:
        return error(value, error);
    }
  }

  R maybeWhen<R>({
    R Function(T? value)? initial,
    R Function(T? value)? loading,
    R Function(T value)? success,
    R Function(T? value, Object error)? error,
    required R Function(T? value) orElse,
  }) {
    switch (status) {
      case AsyncStatus.initial:
        return initial?.call(value) ?? orElse(value);
      case AsyncStatus.loading:
        return loading?.call(value) ?? orElse(value);
      case AsyncStatus.success:
        return success?.call(value as T) ?? orElse(value);
      case AsyncStatus.error:
        return error?.call(value, error) ?? orElse(value);
    }
  }

  AsyncData<T> copyWith({T? value, AsyncStatus? status, Object? error}) {
    return AsyncData._(
      value: value ?? this.value,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  static AsyncData<T> loading<T>([T? value]) =>
      AsyncData._(value: value, status: AsyncStatus.loading);

  static AsyncData<T> success<T>(T value) =>
      AsyncData._(value: value, status: AsyncStatus.success);

  static AsyncData<T> failed<T>(Object error, [T? value]) =>
      AsyncData._(value: value, status: AsyncStatus.error, error: error);

  static AsyncData<T> initial<T>([T? value]) =>
      AsyncData._(value: value, status: AsyncStatus.initial);

  @override
  String toString() {
    return 'AsyncData{value: $value, status: $status, error: $error}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncData &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          status == other.status &&
          error == other.error;

  @override
  int get hashCode => value.hashCode ^ status.hashCode ^ error.hashCode;
}

abstract class StateNotifier<T> extends ChangeNotifier {
  StateNotifier(this._state) {
    init();
  }

  T _state;
  T get state => _state;

  set state(T value) {
    if (value == _state) return;
    _state = value;
    notifyListeners();
  }

  void init() {}

  void update(T Function(T state) updater) {
    state = updater(_state);
  }

  @override
  void dispose();
}

abstract class AsyncStateNotifier<T> extends StateNotifier<AsyncData<T>> {
  AsyncStateNotifier([T? initialValue])
    : super(AsyncData.initial(initialValue));

  void setLoading([T? value]) {
    state = AsyncData.loading(value ?? state.value);
  }

  void setSuccess(T value) {
    state = AsyncData.success(value);
  }

  void setFailed(Object error, [T? value]) {
    state = AsyncData.failed(error, value ?? state.value);
  }

  Future<T> Function()? _lastExecuted;

  Future execute(Future<T> Function() future) async {
    setLoading();
    try {
      final result = await future();
      setSuccess(result);
    } catch (e) {
      setFailed(e);
    }
    _lastExecuted = future;
  }

  void reload() {
    if (_lastExecuted != null) {
      execute(_lastExecuted!);
    }
  }

  void retry() => reload();
}

class StateProvider<T extends ChangeNotifier> extends InheritedNotifier {
  const StateProvider({
    super.key,
    required T super.notifier,
    required super.child,
  });

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<StateProvider<T>>();
    assert(provider != null, 'No StateProvider found in context for $T');
    return provider!.notifier as T;
  }
}

class MultiProvider extends StatelessWidget {
  final List<StateProvider> providers;
  final Widget child;
  const MultiProvider({
    super.key,
    required this.providers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    for (final provider in providers.reversed) {
      result = StateProvider(
        notifier: provider.notifier as ChangeNotifier,
        child: child,
      );
    }
    return result;
  }
}

class StateConsumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T notifier) builder;

  const StateConsumer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final notifier = StateProvider.of<T>(context);
    return builder(context, notifier);
  }
}

class AsyncStateConsumer<T extends AsyncStateNotifier<D>, D>
    extends StatelessWidget {
  final Widget Function(BuildContext context, D value)? onSuccess;
  final Widget Function(BuildContext context)? onLoading;
  final Widget Function(BuildContext context, Object error)? onError;
  final Widget Function(BuildContext context)? onInitial;
  final Widget Function(BuildContext context, AsyncData<D> data, T notifier)?
  builder;

  const AsyncStateConsumer({
    super.key,
    this.onSuccess,
    this.onLoading,
    this.onError,
    this.onInitial,
    this.builder,
  }) : assert(
         onSuccess != null || builder != null,
         'Either builder or onSuccess must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final notifier = StateProvider.of<T>(context);

    if (builder != null) {
      return builder!(context, notifier.state, notifier);
    }

    return notifier.state.when(
      initial: (_) =>
          onInitial?.call(context) ??
          const Center(child: Text('Initializing...')),
      loading: (_) =>
          onLoading?.call(context) ??
          const Center(child: CircularProgressIndicator()),
      success: (value) => onSuccess!(context, value!),
      error: (err, _) =>
          onError?.call(context, err!) ?? Center(child: Text('Error: $err')),
    );
  }
}
