library;

import 'package:flutter/material.dart';
import 'subscribable.dart';

mixin BaseController {
  final List<Subscription> _subscriptions = [];

  void listen<T>(
    Subscribable<T> subscribable,
    ValueChanged<T> onData, {
    bool immediate = false,
  }) {
    final sub = subscribable.subscribe(onData, immediate: immediate);
    _subscriptions.add(sub);
  }

  /// Clean up all subscriptions
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}
