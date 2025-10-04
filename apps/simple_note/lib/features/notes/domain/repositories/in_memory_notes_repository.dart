import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';

class InMemoryNotesRepository implements NotesRepository {
  final _notes = [
    NoteEntity(id: 1, title: 'Hi This is a note', content: 'Writing note here'),
    NoteEntity(id: 2, title: 'Going to sleep', content: 'Writing note here'),
    NoteEntity(id: 3, title: 'What is this', content: 'What is this?'),
  ];

  @override
  Future<void> addNote(NoteEntity note) async {
    _notes.add(note);
  }

  @override
  Future<List<NoteEntity>> getNotes() async {
    return _notes;
  }

  @override
  Future<void> deleteNote(int id) async {
    _notes.removeWhere((note) => note.id == id);
  }

  @override
  Future<NoteEntity?> getNoteById(int id) async {
    return _notes.firstWhere((note) => note.id == id);
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    _notes[index] = note;
  }
}
