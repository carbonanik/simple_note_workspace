import 'package:flutter/material.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';

class NoteEditorPage extends StatelessWidget {
  final NoteEntity? note;
  const NoteEditorPage({this.note, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Editor'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => NotesPage()),
              // );
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(controller: TextEditingController(text: note?.title)),
          TextField(controller: TextEditingController(text: note?.content)),
        ],
      ),
    );
  }
}
