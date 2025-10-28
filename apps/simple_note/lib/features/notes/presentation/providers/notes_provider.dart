import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_note/features/notes/data/repositories/network_note_repository.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';

part 'notes_provider.g.dart';

@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  FutureOr<List<NoteEntity>> build() async {
    return await load();
  }

  Future<List<NoteEntity>> load() async {
    final repository = ref.read(networkNotesRepositoryProvider);
    return await repository.getNotes();
  }
}

@riverpod
Future<NoteEntity?> noteDetail(Ref ref, int noteId) async {
  final repository = ref.read(networkNotesRepositoryProvider);
  return await repository.getNoteById(noteId);
}
