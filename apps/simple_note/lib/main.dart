import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = Controller();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Subscribe(
          subscribable: controller.data,
          builder: (data) {
            return Text(data);
          },
        ),
      ),
    );
  }
}

// network calls
class Response {}

abstract class SimpleHttp {
  // return future with req data
  // throws error
  Future<Response> get();
}

// reactive
class Subscribable<T> {
  Subscribable(T initial) : _value = initial;
  T _value;
  final Map<Object, Function(T value)> _subscribers = {};

  get value => _value;

  set value(T value) {
    _value = value;
    _notifySubscriber(_value);
  }

  _notifySubscriber(T value) {
    for (var subscriber in _subscribers.values) {
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

class BaseController {
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

class Control ler extends BaseController {
  final Subscribable<String> data = Subscribable('value');

  Controller() {
    getDate();
    listen(data, immediate: true, (value) {
      debugPrint('data changed: $value');
    });
  }

  Future<void> getDate() async {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      data.value = DateTime.now().toIso8601String();
    });
    data.value = 'new value';
  }
}

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
