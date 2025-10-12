class NoteEntity {
  final int? id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NoteEntity({
    this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  NoteEntity copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NoteEntity.create() {
    return NoteEntity(title: '', content: '');
  }
}
