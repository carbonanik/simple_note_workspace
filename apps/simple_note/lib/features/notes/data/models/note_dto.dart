import 'package:simple_note/features/notes/domain/entities/note.dart';

class NoteDto {
  final int? id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NoteDto({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // For creating notes (no id)
  Map<String, dynamic> toCreateJson() {
    return {'title': title, 'content': content};
  }

  NoteEntity toEntity() {
    return NoteEntity(
      id: id ?? -1,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NoteDto.fromEntity(NoteEntity note) {
    return NoteDto(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }
}
