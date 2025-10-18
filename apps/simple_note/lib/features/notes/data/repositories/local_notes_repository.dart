import 'dart:async';

import 'package:simple_note/features/notes/data/datasources/local/notes_local_datasource.dart';
import 'package:simple_note/features/notes/data/models/notes_model.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

class LocalNotesRepository implements NotesRepository {
  final NotesLocalDataSource localDataSource;

  LocalNotesRepository(this.localDataSource);

  @override
  Future<List<NoteEntity>> getNotes() async {
    final models = await localDataSource.getNotes();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> addNote(NoteEntity note) =>
      localDataSource.addNote(NoteModel.fromEntity(note));

  @override
  Future<void> updateNote(NoteEntity note) =>
      localDataSource.updateNote(NoteModel.fromEntity(note));

  @override
  Future<void> deleteNote(int id) => localDataSource.deleteNote(id);

  @override
  Future<NoteEntity?> getNoteById(int id) async {
    final model = await localDataSource.getNoteById(id);
    return model?.toEntity();
  }
}
