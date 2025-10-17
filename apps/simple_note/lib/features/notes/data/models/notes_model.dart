import 'package:drift/drift.dart';
import 'package:simple_note/core/database/drift_database.dart';
import 'package:simple_note/features/notes/domain/entities/note.dart';

class NoteModel {
  final int? id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NoteModel({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory NoteModel.fromEntity(NoteEntity entity) => NoteModel(
    id: entity.id,
    title: entity.title,
    content: entity.content,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  NoteEntity toEntity() => NoteEntity(
    id: id,
    title: title,
    content: content,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory NoteModel.fromDrift(NoteTableData data) => NoteModel(
    id: data.id,
    title: data.title,
    content: data.content,
    createdAt: data.createdAt,
    updatedAt: data.updatedAt,
  );

  NoteTableCompanion toDriftCompanion() => NoteTableCompanion(
    title: Value(title),
    content: Value(content),
    createdAt: Value(createdAt ?? DateTime.now()),
    updatedAt: Value(updatedAt ?? DateTime.now()),
  );
}
