import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

enum NotesStatus { initial, loading, success, error }

class NotesController extends ChangeNotifier {
  final NotesRepository notesRepository;
  NotesController(this.notesRepository);

  List<NoteEntity> _notes = [];
  NotesStatus _status = NotesStatus.initial;
  String? _errorMessage;

  UnmodifiableListView<NoteEntity> get notes => UnmodifiableListView(_notes);
  NotesStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == NotesStatus.loading;
  bool get hasError => _status == NotesStatus.error;
  bool get isSuccess => _status == NotesStatus.success;

  Future<void> getNotes() async {
    _status = NotesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _notes = await notesRepository.getNotes();
      _status = NotesStatus.success;
    } catch (e) {
      _status = NotesStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> addNote(NoteEntity note) async {
    try {
      await notesRepository.addNote(note);
      _notes = await notesRepository.getNotes();
      _status = NotesStatus.success;
      notifyListeners();
    } catch (e) {
      _status = NotesStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await notesRepository.deleteNote(id);
      _notes = await notesRepository.getNotes();
      _status = NotesStatus.success;
      notifyListeners();
    } catch (e) {
      _status = NotesStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNote(NoteEntity note) async {
    try {
      await notesRepository.updateNote(note);
      _notes = await notesRepository.getNotes();
      _status = NotesStatus.success;
      notifyListeners();
    } catch (e) {
      _status = NotesStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
