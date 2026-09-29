import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user has an existing session
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with email and password
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Login with an authenticated Google account.
class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

/// Register a new user
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String role;
  final String? phone;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, fullName, role, phone];
}

/// Logout current user
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Update user profile
class AuthProfileUpdateRequested extends AuthEvent {
  final String? fullName;
  final String? phone;
  final String? avatarUrl;

  const AuthProfileUpdateRequested({
    this.fullName,
    this.phone,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [fullName, phone, avatarUrl];
}
