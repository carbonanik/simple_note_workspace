import 'package:flutter/material.dart';
import 'package:simple_state/src/providers/state_provider.dart';

class StateConsumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T notifier) builder;

  const StateConsumer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final notifier = StateProvider.of<T>(context);
    return builder(context, notifier);
  }
}
