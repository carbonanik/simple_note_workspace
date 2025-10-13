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

  bool validateForm() => formKey.currentState!.validate();

  Future<Result<void>> save() async {
    final note = state.value!.copyWith(
      title: titleController.text,
      content: contentController.text,
    );
    try {
      if (note.id == null) {
        await addNote(note);
      } else {
        await updateNote(note);
      }
      return Success(null);
    } catch (e) {
      return Error(e.toString());
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

class Result<T> {
  const Result();

  get isSuccess => this is Success;
  get isError => this is Error;

  get successValue => (this as Success).value;
  get errorMessage => (this as Error).message;
}

class Success<T> extends Result<T> {
  final T value;
  Success(this.value);
}

class Error<T> extends Result<T> {
  final String message;
  Error(this.message);
}
