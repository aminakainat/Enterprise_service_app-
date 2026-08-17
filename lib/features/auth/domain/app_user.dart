enum UserRole {
  admin,
  technician;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin / Dispatcher';
      case UserRole.technician:
        return 'Field Technician';
    }
  }

  static UserRole fromString(String value) {
    if (value.toLowerCase() == 'admin') return UserRole.admin;
    return UserRole.technician;
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? photoUrl;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isTechnician => role == UserRole.technician;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone ?? '',
      'photoUrl': photoUrl ?? '',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String docId) {
    return AppUser(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'technician'),
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
