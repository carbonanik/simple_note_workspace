import 'package:flutter/material.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/presentation/controllers/notes_controller.dart';
import 'package:simple_note/features/notes/presentation/pages/widgets/notes_empty_state.dart';
import 'package:simple_note/features/notes/presentation/pages/widgets/notes_error_state.dart';
import 'package:simple_note/features/notes/presentation/pages/widgets/notes_grid.dart';
import 'package:simple_note/features/notes/presentation/pages/note_editor_page.dart';
import 'package:simple_note/features/notes/presentation/pages/widgets/notes_loading_state.dart';
import 'package:simple_state/simple_state.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: AsyncStateConsumer<NotesController, List<NoteEntity>>(
        onSuccess: (context, notes, notifier) {
          if (notes.isEmpty) {
            return const NotesEmptyState();
          }
          return NotesGrid(notes: notes);
        },
        onLoading: (_, __) => const NotesLoadingState(),
        onError: (_, error, notifier) =>
            NotesErrorState(error: error, onRetry: notifier.reload),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_note_fab'),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorPage()),
          );
        },
      ),
    );
  }
}
