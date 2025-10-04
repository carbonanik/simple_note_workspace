class NoteEntity {
  final int id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });
}
