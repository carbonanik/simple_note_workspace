library;

import 'package:flutter/material.dart';
import 'subscribable.dart';

abstract class BaseController with Disposable, ListenToSubscribable {
  BaseController() {
    init();
  }
  init() {}

  @override
  void listen<T>(
    Subscribable<T> subscribable,
    ValueChanged<T> onData, {
    bool immediate = false,
  }) {
    super.listen(subscribable, onData, immediate: immediate);
  }

  @override
  void dispose() {
    cancelSubscriptions();
  }
}

mixin ListenToSubscribable {
  final List<Subscription> _subscriptions = [];

  void listen<T>(
    Subscribable<T> subscribable,
    ValueChanged<T> onData, {
    bool immediate = false,
  }) {
    final sub = subscribable.subscribe(onData, immediate: immediate);
    _subscriptions.add(sub);
  }

  void cancelSubscriptions() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}

mixin Disposable {
  void dispose();
}
