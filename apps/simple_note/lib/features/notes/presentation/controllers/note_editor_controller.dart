import 'package:flutter/material.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';
import 'package:simple_state/simple_state.dart';

class NoteEditorController extends AsyncStateNotifier<NoteEntity> {
  final NotesRepository _repository;
  NoteEditorController(this._repository, {int? noteId})
    : currentNoteId = noteId;

  int? currentNoteId;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void init() => execute(() {
    return _getNoteById(currentNoteId);
  });

  Future<NoteEntity> _getNoteById(int? id) async {
    if (id == null) {
      return NoteEntity.create();
    }
    final note = await _repository.getNoteById(id);
    if (note == null) {
      throw Exception('Note with id $id not found');
    }
    titleController.text = note.title;
    contentController.text = note.content;
    return note;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final note = state.value!.copyWith(
      title: titleController.text,
      content: contentController.text,
    );
    if (note.id == null) {
      await addNote(note);
    } else {
      await updateNote(note);
    }
  }

  Future<void> addNote(NoteEntity note) async {
    final newId = await _repository.addNote(note);
    currentNoteId = newId;
  }

  Future<void> deleteNote(int id) async {
    await _repository.deleteNote(id);
  }

  Future<void> updateNote(NoteEntity note) async {
    await _repository.updateNote(note);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
