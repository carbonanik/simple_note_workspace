import 'package:flutter/material.dart';

class NotesEmptyState extends StatelessWidget {
  const NotesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: Key('empty_state'),
      child: Text('No notes yet. Tap + to create one!'),
    );
  }
}
