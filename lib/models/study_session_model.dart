class StudySession {
  final String id;
  final String userId;
  final double studyHours;
  final double screenTime;
  DateTime date;
  final String? notes;
  final double productivityPercentage;

  StudySession({
    required this.id,
    required this.userId,
    required this.studyHours,
    required this.screenTime,
    required this.date,
    this.notes,
    required this.productivityPercentage,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      studyHours: (json['studyHours'] ?? 0).toDouble(),
      screenTime: (json['screenTime'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
      notes: json['notes'],
      productivityPercentage: (json['productivityPercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'studyHours': studyHours,
      'screenTime': screenTime,
      'date': date.toIso8601String(),
      'notes': notes,
      'productivityPercentage': productivityPercentage,
    };
  }
}
