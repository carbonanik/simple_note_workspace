library;

import 'package:flutter/material.dart';
import 'subscribable.dart';

class Subscribe<T> extends StatefulWidget {
  final Subscribable<T> subscribable;
  final Widget Function(T value) builder;
  const Subscribe({
    required this.subscribable,
    required this.builder,
    super.key,
  });

  @override
  State<Subscribe<T>> createState() => _SubscribeState<T>();
}

class _SubscribeState<T> extends State<Subscribe<T>> {
  late T _value;
  Subscription? _subscription;

  subscriber(T value) {
    setState(() => _value = value);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.subscribable.value;
    _subscription = widget.subscribable.subscribe(subscriber, immediate: true);
  }

  @override
  void didUpdateWidget(covariant Subscribe<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.subscribable != oldWidget.subscribable) {
      _subscription?.cancel();
      _subscription = widget.subscribable.subscribe(
        subscriber,
        immediate: true,
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_value);
  }
}
