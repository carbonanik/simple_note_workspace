import 'package:simple_note/features/notes/domain/entities/note.dart';

import 'package:json_annotation/json_annotation.dart';

part 'network_note_model.g.dart';

@JsonSerializable()
class NetworkNoteModel {
  final int? id;
  final String title;
  final String content;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  NetworkNoteModel({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  factory NetworkNoteModel.fromJson(Map<String, dynamic> json) =>
      _$NetworkNoteModelFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkNoteModelToJson(this);

  // Convert from domain entity
  factory NetworkNoteModel.fromEntity(NoteEntity entity) {
    return NetworkNoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  // Convert to domain entity
  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}

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

  static List<NoteDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NoteDto.fromJson(json)).toList();
  }

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
