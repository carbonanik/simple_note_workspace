import 'package:flutter/material.dart';
import 'package:simple_note/app_dependencies.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/presentation/pages/note_editor_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notesController = AppDependencies.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: ListenableBuilder(
        listenable: notesController,
        builder: (context, child) {
          if (notesController.isLoading) {
            return const Center(
              key: Key('loading_indicator'),
              child: CircularProgressIndicator(),
            );
          }

          if (notesController.hasError) {
            return Center(
              key: const Key('error_widget'),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${notesController.errorMessage}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    key: const Key('retry_button'),
                    onPressed: () => notesController.getNotes(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (notesController.notes.isEmpty) {
            return const Center(
              key: Key('empty_state'),
              child: Text('No notes yet. Tap + to create one!'),
            );
          }

          return NotesGrid(notes: notesController.notes);
        },
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

class NotesGrid extends StatelessWidget {
  final List<NoteEntity> notes;

  const NotesGrid({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const Key('notes_grid'),
      padding: const EdgeInsets.all(8),
      itemCount: notes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(note: note, index: index);
      },
    );
  }
}

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final int index;

  const NoteCard({super.key, required this.note, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        key: Key('note_tile_$index'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteEditorPage(note: note)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                key: Key('note_title_$index'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  key: Key('note_content_$index'),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
