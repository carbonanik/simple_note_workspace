import 'package:flutter/material.dart';
import 'package:simple_note/core/sl/sl.dart';
import 'package:simple_note/core/utils/snack_bar_extension.dart';
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
            onPressed: () => _handleSave(context),
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

  void _handleSave(BuildContext context) async {
    final controller = context.read<NoteEditorController>();
    if (!controller.validateForm()) return;
    final result = await controller.save();

    if (!context.mounted) return;

    if (result.isSuccess) {
      context.read<NotesController>().reload();
      context.showSnackBar('Note saved successfully');
    }

    if (result.isError) {
      context.showSnackBar('Failed to save note');
    }
  }
}
