import 'package:equatable/equatable.dart';
import '../../../models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — checking stored session
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Successfully authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Not authenticated — show login screen
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Auth error
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
