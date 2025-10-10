library;

import 'package:flutter/material.dart';

class Subscribable<T> {
  Subscribable(T initial, {this.validator}) : _value = initial;

  T _value;
  final T Function(T)? validator;
  final Map<Object, ValueChanged<T>> _subscribers = {};

  T get value => _value;

  set value(T newValue) {
    final validatedValue = validator != null ? validator!(newValue) : newValue;
    if (_value != validatedValue) {
      _value = newValue;
      _notifySubscriber(_value);
    }
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

  Subscribable<R> map<R>(R Function(T) mapper) {
    final computed = Subscribable<R>(mapper(_value));
    subscribe((value) {
      computed.value = mapper(value);
    });
    return computed;
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
