class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> attachments;
  final String visibility; // 'public', 'private'
  final List<String> sharedWithUsers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.attachments = const [],
    this.visibility = 'private',
    this.sharedWithUsers = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      visibility: json['visibility'] ?? 'private',
      sharedWithUsers: List<String>.from(json['sharedWithUsers'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'attachments': attachments,
      'visibility': visibility,
      'sharedWithUsers': sharedWithUsers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
