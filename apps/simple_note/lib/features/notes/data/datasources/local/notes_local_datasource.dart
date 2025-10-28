import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:simple_note/core/database/drift_database.dart';
import 'package:simple_note/features/notes/data/models/notes_model.dart';

part 'notes_local_datasource.g.dart';

class NotesLocalDataSource {
  final AppDatabase db;
  NotesLocalDataSource(this.db);

  Future<List<NoteModel>> getNotes() async {
    final rows = await db.select(db.noteTable).get();
    return rows.map(NoteModel.fromDrift).toList();
  }

  Future<int> addNote(NoteModel note) async {
    return await db.into(db.noteTable).insert(note.toDriftCompanion());
  }

  Future<void> updateNote(NoteModel note) async {
    await (db.update(
      db.noteTable,
    )..where((t) => t.id.equals(note.id!))).write(note.toDriftCompanion());
  }

  Future<void> deleteNote(int id) async {
    await (db.delete(db.noteTable)..where((t) => t.id.equals(id))).go();
  }

  Future<NoteModel?> getNoteById(int id) async {
    final row = await (db.select(
      db.noteTable,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? NoteModel.fromDrift(row) : null;
  }
}

@riverpod
NotesLocalDataSource notesLocalDataSource(Ref ref) {
  final db = ref.read(appDatabaseProvider);
  return NotesLocalDataSource(db);
}
