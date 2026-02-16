class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String mobileNumber;
  final String role; // 'admin' or 'user'
  final String? profilePhotoUrl;
  final String? bio;
  final bool isDarkMode;
  final DateTime createdAt;
  final bool isOnline;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.mobileNumber,
    required this.role,
    this.profilePhotoUrl,
    this.bio,
    this.isDarkMode = false,
    required this.createdAt,
    this.isOnline = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      role: json['role'] ?? 'user',
      profilePhotoUrl: json['profilePhotoUrl'],
      bio: json['bio'],
      isDarkMode: json['isDarkMode'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'role': role,
      'profilePhotoUrl': profilePhotoUrl,
      'bio': bio,
      'isDarkMode': isDarkMode,
      'createdAt': createdAt.toIso8601String(),
      'isOnline': isOnline,
    };
  }
}
