import 'package:equatable/equatable.dart';
import '../core/constants/enums.dart';

/// User data model
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;
  final bool isBanned;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.isBanned = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      fullName: map['full_name'] as String,
      role: UserRole.fromString(map['role'] as String),
      avatarUrl: map['avatar_url'] as String?,
      isBanned: (map['is_banned'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'role': role.name,
      'avatar_url': avatarUrl,
      'is_banned': isBanned ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? fullName,
    UserRole? role,
    String? avatarUrl,
    bool? isBanned,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        fullName,
        role,
        avatarUrl,
        isBanned,
        createdAt,
      ];
}
