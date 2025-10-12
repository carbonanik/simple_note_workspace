import 'package:flutter/material.dart';
import 'package:simple_state/src/async_data.dart';
import 'package:simple_state/src/notifiers/async_state_notifier.dart';
import 'package:simple_state/src/providers/state_provider.dart';

class AsyncStateConsumer<T extends AsyncStateNotifier<D>, D>
    extends StatelessWidget {
  final Widget Function(BuildContext context, D value, T notifier)? onSuccess;
  final Widget Function(BuildContext context, T notifier)? onLoading;
  final Widget Function(BuildContext context, Object? error, T notifier)?
  onError;
  final Widget Function(BuildContext context, T notifier)? onInitial;
  final Widget Function(BuildContext context, AsyncData<D> data, T notifier)?
  builder;

  const AsyncStateConsumer({
    super.key,
    this.onSuccess,
    this.onLoading,
    this.onError,
    this.onInitial,
    this.builder,
  }) : assert(
         onSuccess != null || builder != null,
         'Either builder or onSuccess must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final notifier = StateProvider.of<T>(context);

    if (builder != null) {
      return builder!(context, notifier.state, notifier);
    }

    return notifier.state.when(
      initial: (_) =>
          onInitial?.call(context, notifier) ??
          const Center(child: Text('Initializing...')),
      loading: (_) =>
          onLoading?.call(context, notifier) ??
          const Center(child: CircularProgressIndicator()),
      success: (value) => onSuccess!(context, value!, notifier),
      error: (_, err) =>
          onError?.call(context, err, notifier) ??
          Center(child: Text('Error: $err')),
    );
  }
}
