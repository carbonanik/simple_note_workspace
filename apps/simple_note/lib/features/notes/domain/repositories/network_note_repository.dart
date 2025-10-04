import 'package:simple_note/features/notes/data/datasources/remote/note_model.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_remote_data_source.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

class NetworkNotesRepository implements NotesRepository {
  final NotesRemoteDataSource dataSource;

  NetworkNotesRepository(this.dataSource);
  @override
  Future<void> addNote(NoteEntity note) async {
    dataSource.createNote(NoteModel.fromEntity(note));
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    final notes = await dataSource.getNotes();
    return notes.map((note) => note.toEntity()).toList();
  }

  @override
  Future<void> deleteNote(int id) async {
    await dataSource.deleteNote(id);
  }

  @override
  Future<NoteEntity?> getNoteById(int id) async {
    final note = await dataSource.getNoteById(id);
    return note.toEntity();
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    await dataSource.updateNote(note.id, NoteModel.fromEntity(note));
  }
}
