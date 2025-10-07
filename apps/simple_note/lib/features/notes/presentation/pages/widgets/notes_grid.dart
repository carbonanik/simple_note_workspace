import 'package:flutter/material.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/presentation/pages/widgets/note_card.dart';

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
