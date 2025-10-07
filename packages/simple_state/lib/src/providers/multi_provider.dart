import 'package:flutter/material.dart';
import 'package:simple_state/src/providers/state_provider.dart';

class MultiProvider extends StatelessWidget {
  final List<StateProvider> providers;
  final Widget child;
  const MultiProvider({
    super.key,
    required this.providers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    for (final provider in providers.reversed) {
      result = StateProvider(
        notifier: provider.notifier as ChangeNotifier,
        child: child,
      );
    }
    return result;
  }
}
