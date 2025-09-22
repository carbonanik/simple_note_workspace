library;

import 'package:flutter/material.dart';

class Subscribable<T> {
  Subscribable(T initial) : _value = initial;
  T _value;
  final Map<Object, ValueChanged<T>> _subscribers = {};

  get value => _value;

  set value(T value) {
    _value = value;
    _notifySubscriber(_value);
  }

  _notifySubscriber(T value) {
    for (var subscriber in List.of(_subscribers.values)) {
      try {
        subscriber(value);
      } catch (e, st) {
        debugPrint("Subscriber threw: $e\n$st");
      }
    }
  }

  Subscription subscribe(ValueChanged<T> subscriber, {bool immediate = false}) {
    final key = Object();

    _subscribers[key] = subscriber;

    if (immediate) {
      subscriber(_value);
    }

    return Subscription(() {
      _subscribers.remove(key);
    });
  }
}

class Subscription {
  final Function _onCancel;
  Subscription(this._onCancel);

  bool _isCanceled = false;

  void cancel() {
    if (!_isCanceled) {
      _onCancel.call();
      _isCanceled = true;
    }
  }
}
