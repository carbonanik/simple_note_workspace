import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';
import 'package:simple_state/simple_state.dart';

class NotesController extends AsyncStateNotifier<List<NoteEntity>> {
  final NotesRepository _repository;
  NotesController(this._repository);

  @override
  void init() => execute(_repository.getNotes);

  Future<void> addNote(NoteEntity note) async {
    await _repository.addNote(note);
    reload();
  }

  Future<void> deleteNote(int id) async {
    await _repository.deleteNote(id);
    reload();
  }

  Future<void> updateNote(NoteEntity note) async {
    await _repository.updateNote(note);
    reload();
  }
}
