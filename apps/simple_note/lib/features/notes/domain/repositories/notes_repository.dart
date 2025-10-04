import 'package:simple_note/features/notes/domain/entities/note.dart';

abstract interface class NotesRepository {
  Future<List<NoteEntity>> getNotes();
  Future<void> addNote(NoteEntity note);
  Future<void> updateNote(NoteEntity note);
  Future<void> deleteNote(int id);
  Future<NoteEntity?> getNoteById(int id);
}
