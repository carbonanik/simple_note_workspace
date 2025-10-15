import 'package:flutter/material.dart';

class StateProvider<T extends ChangeNotifier> extends StatefulWidget {
  final Widget child;
  final T notifier;
  const StateProvider({super.key, required this.notifier, required this.child});

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_StateProviderInheritedWidget<T>>();
    assert(provider != null, 'No StateProvider found in context for $T');
    return provider!.notifier as T;
  }

  static T? maybeOf<T extends ChangeNotifier>(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_StateProviderInheritedWidget<T>>();
    return provider?.notifier as T?;
  }

  @override
  State<StateProvider<T>> createState() => _StateProviderState();
}

class _StateProviderState<T extends ChangeNotifier>
    extends State<StateProvider<T>> {
  @override
  void dispose() {
    widget.notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StateProviderInheritedWidget(
      notifier: widget.notifier,
      child: widget.child,
    );
  }
}

class _StateProviderInheritedWidget<T extends ChangeNotifier>
    extends InheritedNotifier {
  const _StateProviderInheritedWidget({
    required T super.notifier,
    required super.child,
  });
}

extension StateReader on BuildContext {
  T read<T extends ChangeNotifier>() {
    final provider =
        getInheritedWidgetOfExactType<_StateProviderInheritedWidget<T>>();
    assert(provider != null, 'No StateProvider found in context for $T');
    return provider!.notifier as T;
  }
}
