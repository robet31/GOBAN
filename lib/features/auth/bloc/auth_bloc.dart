import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
/// Manages login, registration, session check, and logout
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  AuthService get authService => _authService;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.tryAutoLogin();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        role: event.role,
        phone: event.phone,
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Registrasi gagal. Silakan coba lagi.'));
    }
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.loginWithGoogle();
      emit(
          user == null ? const AuthUnauthenticated() : AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Google sign-in gagal. Silakan coba lagi.'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authService.updateProfile(
        fullName: event.fullName,
        phone: event.phone,
        avatarUrl: event.avatarUrl,
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    }
  }
}
