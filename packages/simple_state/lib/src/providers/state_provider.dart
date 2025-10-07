import 'package:flutter/material.dart';

class StateProvider<T extends ChangeNotifier> extends InheritedNotifier {
  const StateProvider({
    super.key,
    required T super.notifier,
    required super.child,
  });

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<StateProvider<T>>();
    assert(provider != null, 'No StateProvider found in context for $T');
    return provider!.notifier as T;
  }
}
