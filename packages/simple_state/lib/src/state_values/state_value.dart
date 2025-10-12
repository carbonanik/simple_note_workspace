import 'package:flutter/material.dart';

class StateValue<T> extends ChangeNotifier {
  T _value;
  StateValue(this._value);
  T get value => _value;

  set value(T value) {
    _value = value;
    notifyListeners();
  }

  T call() => _value;

  void update(T Function(T state) updater) {
    _value = updater(_value);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  StateValue<R> map<R>(R Function(T) mapper) {
    final mapped = StateValue<R>(mapper(_value));
    addListener(() {
      mapped.value = mapper(_value);
    });
    return mapped;
  }

  @override
  String toString() {
    return 'StateValue<$T>($value)';
  }
}
