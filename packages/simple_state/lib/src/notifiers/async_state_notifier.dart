import 'package:simple_state/src/async_data.dart';
import 'package:simple_state/src/notifiers/state_notifier.dart';

abstract class AsyncStateNotifier<T> extends StateNotifier<AsyncData<T>> {
  AsyncStateNotifier([T? initialValue]) : super(AsyncData.initial(initialValue));

  T? get data => state.value;

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
