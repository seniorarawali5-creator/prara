class ChatMessage {
  final String id;
  final String? chatId;
  final String? groupId;
  final String senderId;
  final String? receiverId;
  final String text;
  final List<String> attachments;
  final DateTime timestamp;
  final bool isRead;
  final String messageType; // 'text', 'image', 'pdf', 'file'
  final String? attachmentURL;

  ChatMessage({
    required this.id,
    this.chatId,
    this.groupId,
    required this.senderId,
    this.receiverId,
    required this.text,
    this.attachments = const [],
    required this.timestamp,
    this.isRead = false,
    this.messageType = 'text',
    this.attachmentURL,
  });

  DateTime get createdAt => timestamp;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      chatId: json['chatId'],
      groupId: json['groupId'],
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'],
      text: json['text'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      timestamp: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      isRead: json['isRead'] ?? false,
      messageType: json['messageType'] ?? 'text',
      attachmentURL: json['attachmentURL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'attachments': attachments,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'messageType': messageType,
    };
  }
}
