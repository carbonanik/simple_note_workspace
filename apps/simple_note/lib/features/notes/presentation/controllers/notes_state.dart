import 'package:simple_note/features/notes/domain/entities/note.dart';

class NotesState {
  final List<NoteEntity> notes;
  const NotesState({required this.notes});
}
