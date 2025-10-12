import 'package:simple_note/features/notes/domain/entities/note.dart';
import 'package:simple_note/features/notes/domain/repositories/notes_repository.dart';
import 'package:simple_state/simple_state.dart';

class NotesController extends AsyncStateNotifier<List<NoteEntity>> {
  final NotesRepository _repository;
  NotesController(this._repository);

  @override
  void init() => execute(_repository.getNotes);
}
