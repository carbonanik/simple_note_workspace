import 'package:flutter/material.dart';
import 'package:simple_note/core/sl/sl.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/presentation/controllers/note_editor_controller.dart';
import 'package:simple_note/features/notes/presentation/controllers/notes_controller.dart';
import 'package:simple_state/simple_state.dart';

class NoteEditorFlow extends StatelessWidget {
  final int? noteId;
  const NoteEditorFlow({super.key, this.noteId});

  @override
  Widget build(BuildContext context) {
    return StateProvider(
      notifier: NoteEditorController(SL().get(), noteId: noteId),
      child: const NoteEditorPage(),
    );
  }
}

class NoteEditorPage extends StatelessWidget {
  const NoteEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Editor'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await context.read<NoteEditorController>().save();
                if (!context.mounted) return;
                context.read<NotesController>().reload();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note saved successfully')),
                );
              } catch (e) {
                debugPrint(e.toString());
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed to save note')));
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: AsyncStateConsumer<NoteEditorController, NoteEntity>(
        builder: (context, note, notifier) {
          return Form(
            key: notifier.formKey,
            child: Column(
              children: [
                TextField(controller: notifier.titleController),
                TextField(controller: notifier.contentController),
              ],
            ),
          );
        },
      ),
    );
  }
}
