class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isBlocked;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isBlocked,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isBlocked: json['is_blocked'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_blocked': isBlocked,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}
