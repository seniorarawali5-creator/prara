class Story {
  final String id;
  final String userId;
  final String content;
  final String contentType; // 'text', 'image'
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;

  Story({
    required this.id,
    required this.userId,
    required this.content,
    required this.contentType,
    this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
    this.viewedBy = const [],
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      contentType: json['contentType'] ?? 'text',
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      expiresAt: DateTime.parse(json['expiresAt'] ?? DateTime.now().toString()),
      viewedBy: List<String>.from(json['viewedBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'contentType': contentType,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'viewedBy': viewedBy,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
