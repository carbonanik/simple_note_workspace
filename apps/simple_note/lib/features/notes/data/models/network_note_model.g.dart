// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkNoteModel _$NetworkNoteModelFromJson(Map<String, dynamic> json) =>
    NetworkNoteModel(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$NetworkNoteModelToJson(NetworkNoteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
