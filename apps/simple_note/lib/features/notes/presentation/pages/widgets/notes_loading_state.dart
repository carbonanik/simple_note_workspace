import 'package:flutter/material.dart';

class NotesLoadingState extends StatelessWidget {
  const NotesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: Key('loading_indicator'),
      child: CircularProgressIndicator(),
    );
  }
}
