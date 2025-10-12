enum AsyncStatus { initial, loading, success, error }

class AsyncData<T> {
  final T? value;
  final AsyncStatus status;
  final Object? error;

  /// assert when status is success value can't be null
  const AsyncData._({this.value, required this.status, this.error});

  bool get isInitial => status == AsyncStatus.initial;
  bool get isLoading => status == AsyncStatus.loading;
  bool get hasError => status == AsyncStatus.error;
  bool get isSuccess => status == AsyncStatus.success;

  bool get isEmpty => value == null;

  R when<R>({
    required R Function(T? value) initial,
    required R Function(T? value) loading,
    required R Function(T value) success,
    required R Function(T? value, Object? errorObj) error,
  }) {
    switch (status) {
      case AsyncStatus.initial:
        return initial(value);
      case AsyncStatus.loading:
        return loading(value);
      case AsyncStatus.success:
        return success(value as T);
      case AsyncStatus.error:
        return error(value, this.error);
    }
  }

  R maybeWhen<R>({
    R Function(T? value)? initial,
    R Function(T? value)? loading,
    R Function(T value)? success,
    R Function(T? value, Object? errorObj)? error,
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
        return error?.call(value, this.error) ?? orElse(value);
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
