class UserModel {
  final String id;
  final String nama;
  final String email;
  final String role;
  final bool isActive;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.isActive = true,
    this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      nama: map['nama'],
      email: map['email'],
      role: map['role'],
      isActive: map['is_active'] ?? true,
      avatarUrl: map['avatar_url'],
    );
  }

  UserModel copyWith({
    String? nama,
    String? role,
    bool? isActive,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      nama: nama ?? this.nama,
      email: email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}