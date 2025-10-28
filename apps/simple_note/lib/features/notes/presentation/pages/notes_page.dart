import 'package:flutter/material.dart';
import 'package:simple_note/features/notes/presentation/pages/widgets/notes_empty_state.dart';
import 'package:simple_note/features/notes/presentation/pages/widgets/notes_error_state.dart';
import 'package:simple_note/features/notes/presentation/pages/widgets/notes_grid.dart';
import 'package:simple_note/features/notes/presentation/pages/note_editor_page.dart';
import 'package:simple_note/features/notes/presentation/pages/widgets/notes_loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_note/features/notes/presentation/providers/notes_provider.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Consumer(
        builder: (context, ref, child) {
          final asyncNotes = ref.watch(notesProvider);
          return asyncNotes.when(
            data: (data) {
              final notes = data;
              if (notes.isEmpty) {
                return const NotesEmptyState();
              }
              return NotesGrid(notes: notes);
            },
            error: (error, stackTrace) => NotesErrorState(
              error: error,
              onRetry: () => ref.invalidate(notesProvider),
            ),
            loading: () => const NotesLoadingState(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_note_fab'),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorFlow()),
          );
        },
      ),
    );
  }
}
