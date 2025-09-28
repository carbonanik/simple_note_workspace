import 'package:flutter/material.dart';

class NoteEntity {
  final String id;
  final String title;
  final String content;

  NoteEntity({required this.id, required this.title, required this.content});
}

final notes = [
  NoteEntity(id: '1', title: 'Note 1', content: 'Content 1'),
  NoteEntity(id: '2', title: 'Note 2', content: 'Content 2'),
  NoteEntity(id: '3', title: 'Note 3', content: 'Content 3'),
];

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: GridView.builder(
        itemCount: notes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            child: ListTile(
              title: Text(note.title),
              subtitle: Text(note.content),
            ),
          );
        },
      ),
    );
  }
}
