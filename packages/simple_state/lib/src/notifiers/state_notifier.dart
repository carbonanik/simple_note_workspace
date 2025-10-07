import 'package:flutter/material.dart';

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
