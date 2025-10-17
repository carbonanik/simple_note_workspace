// lib/features/notes/data/repositories/network_notes_repository.dart
import 'package:simple_note/features/notes/data/models/network_note_model.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_network_datasource.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

class NetworkNotesRepository implements NotesRepository {
  final NotesNetworkDataSource networkDataSource;

  NetworkNotesRepository(this.networkDataSource);

  @override
  Future<List<NoteEntity>> getNotes() async {
    final models = await networkDataSource.getNotes();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> addNote(NoteEntity note) async {
    final model = await networkDataSource.createNote(
      NetworkNoteModel.fromEntity(note),
    );
    return model.id ?? 0;
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    await networkDataSource.updateNote(NetworkNoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(int id) async {
    await networkDataSource.deleteNote(id);
  }

  @override
  Future<NoteEntity?> getNoteById(int id) async {
    final model = await networkDataSource.getNoteById(id);
    return model?.toEntity();
  }
}
