class AppProfile {
  final String id;
  final String email;
  final String role;

  const AppProfile({
    required this.id,
    required this.email,
    required this.role,
  });

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  bool get isAdmin => role == 'admin';

  AppProfile copyWith({
    String? id,
    String? email,
    String? role,
  }) {
    return AppProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
