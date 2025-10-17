import 'package:simple_note/features/notes/data/datasources/remote/note_dto.dart';
import 'package:simple_note/features/notes/data/datasources/remote/notes_remote_data_source.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

class NetworkNotesRepository implements NotesRepository {
  final NotesRemoteDataSource dataSource;

  NetworkNotesRepository(this.dataSource);

  @override
  Future<int> addNote(NoteEntity note) async {
    final newNote = await dataSource.createNote(NoteDto.fromEntity(note));
    if (newNote.data?.id == null) {
      throw Exception('Failed to create note');
    }
    return newNote.data!.id!;
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    final notes = await dataSource.getNotes();
    return notes.data?.map((note) => note.toEntity()).toList() ?? [];
  }

  @override
  Future<void> deleteNote(int id) async {
    await dataSource.deleteNote(id);
  }

  @override
  Future<NoteEntity?> getNoteById(int id) async {
    final note = await dataSource.getNoteById(id);
    return note.data?.toEntity();
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    assert(note.id != null);
    await dataSource.updateNote(note.id!, NoteDto.fromEntity(note));
  }
}
