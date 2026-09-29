import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/enums.dart';
import '../models/user_model.dart';
import 'database_service.dart';

/// Custom authentication service using JWT stored in secure storage
/// Handles register, login, logout, and session management
class AuthService {
  final DatabaseService _db;
  final AuthSessionStorage _sessionStorage;
  final GoogleSignInClient _googleSignIn;
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  UserModel? _currentUser;

  AuthService({
    DatabaseService? db,
    FlutterSecureStorage? secureStorage,
    AuthSessionStorage? sessionStorage,
    GoogleSignInClient? googleSignIn,
  })  : _db = db ?? DatabaseService.instance,
        assert(sessionStorage == null || secureStorage == null),
        _sessionStorage =
            sessionStorage ?? SecureAuthSessionStorage(secureStorage),
        _googleSignIn = googleSignIn ?? GoogleSignInClientImpl();

  /// Get current authenticated user
  UserModel? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isAuthenticated => _currentUser != null;

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Generate a simple auth token
  String _generateToken(String userId) {
    final payload = {
      'user_id': userId,
      'iat': DateTime.now().millisecondsSinceEpoch,
      'exp':
          DateTime.now().add(ApiConstants.jwtExpiration).millisecondsSinceEpoch,
    };
    final encoded = base64Encode(utf8.encode(jsonEncode(payload)));
    return encoded;
  }

  /// Validate stored token
  bool _isTokenValid(String token) {
    try {
      final decoded = utf8.decode(base64Decode(token));
      final payload = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = payload['exp'] as int;
      return DateTime.now().millisecondsSinceEpoch < exp;
    } catch (_) {
      return false;
    }
  }

  /// Extract user ID from token
  String? _getUserIdFromToken(String token) {
    try {
      final decoded = utf8.decode(base64Decode(token));
      final payload = jsonDecode(decoded) as Map<String, dynamic>;
      return payload['user_id'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Register a new user
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    // Check if email already exists
    final existing = await _db.query(
      'SELECT id FROM users WHERE email = ?',
      [email],
    );
    if (existing.isNotEmpty) {
      throw AuthException('Email sudah terdaftar');
    }

    // Check if phone already exists
    if (phone != null && phone.isNotEmpty) {
      final existingPhone = await _db.query(
        'SELECT id FROM users WHERE phone = ?',
        [phone],
      );
      if (existingPhone.isNotEmpty) {
        throw AuthException('Nomor HP sudah terdaftar');
      }
    }

    final userId = const Uuid().v4();
    final passwordHash = _hashPassword(password);
    final now = DateTime.now().toIso8601String();

    await _db.execute(
      '''INSERT INTO users (id, email, phone, full_name, role, password_hash, created_at) 
         VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [userId, email, phone, fullName, role, passwordHash, now],
    );

    // Auto-login after registration
    final user = UserModel(
      id: userId,
      email: email,
      phone: phone,
      fullName: fullName,
      role: UserRole.fromString(role),
      createdAt: DateTime.now(),
    );

    await _saveSession(user);
    _currentUser = user;

    // Sync to remote
    await _db.sync();

    return user;
  }

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final passwordHash = _hashPassword(password);

    final results = await _db.query(
      'SELECT * FROM users WHERE email = ? AND password_hash = ?',
      [email, passwordHash],
    );

    if (results.isEmpty) {
      throw AuthException('Email atau password salah');
    }

    final userData = results.first;

    if ((userData['is_banned'] as int? ?? 0) == 1) {
      throw AuthException('Akun Anda telah dinonaktifkan');
    }

    final user = UserModel.fromMap(userData);
    await _saveSession(user);
    _currentUser = user;

    return user;
  }

  /// Sign in with a Google account and map it to the existing local user table.
  /// A cancelled account picker returns null and is not treated as an error.
  Future<UserModel?> loginWithGoogle() async {
    GoogleAccount? account;
    try {
      account = await _googleSignIn.signIn();
    } catch (_) {
      throw const AuthException('Google sign-in gagal. Silakan coba lagi.');
    }

    if (account == null) return null;

    final email = account.email.trim().toLowerCase();
    if (email.isEmpty) {
      throw const AuthException('Google sign-in gagal. Silakan coba lagi.');
    }

    final results = await _db.query('SELECT * FROM users WHERE email = ?', [
      email,
    ]);
    late UserModel user;

    if (results.isEmpty) {
      final userId = const Uuid().v4();
      final fullName = account.displayName?.trim().isNotEmpty == true
          ? account.displayName!.trim()
          : email.split('@').first;
      final now = DateTime.now();
      final placeholderPassword = '${const Uuid().v4()}${const Uuid().v4()}';

      await _db.execute(
        '''INSERT INTO users (id, email, full_name, role, password_hash, avatar_url, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?)''',
        [
          userId,
          email,
          fullName,
          UserRole.customer.name,
          _hashPassword(placeholderPassword),
          account.photoUrl,
          now.toIso8601String(),
        ],
      );
      user = UserModel(
        id: userId,
        email: email,
        fullName: fullName,
        role: UserRole.customer,
        avatarUrl: account.photoUrl,
        createdAt: now,
      );
    } else {
      user = UserModel.fromMap(results.first);
      if (user.isBanned) {
        throw const AuthException('Akun Anda telah dinonaktifkan');
      }

      final photoUrl = account.photoUrl;
      if (photoUrl != null &&
          photoUrl.isNotEmpty &&
          photoUrl != user.avatarUrl) {
        await _db.execute('UPDATE users SET avatar_url = ? WHERE id = ?', [
          photoUrl,
          user.id,
        ]);
        user = user.copyWith(avatarUrl: photoUrl);
      }
    }

    await _saveSession(user);
    _currentUser = user;
    await _db.sync();
    return user;
  }

  /// Logout current user
  Future<void> logout() async {
    await _sessionStorage.delete(_tokenKey);
    await _sessionStorage.delete(_userIdKey);
    _currentUser = null;
  }

  /// Try to restore session from secure storage
  Future<UserModel?> tryAutoLogin() async {
    try {
      final token = await _sessionStorage.read(_tokenKey);
      if (token == null || !_isTokenValid(token)) {
        await logout();
        return null;
      }

      final userId = _getUserIdFromToken(token);
      if (userId == null) {
        await logout();
        return null;
      }

      final results = await _db.query(
        'SELECT * FROM users WHERE id = ?',
        [userId],
      );

      if (results.isEmpty) {
        await logout();
        return null;
      }

      final user = UserModel.fromMap(results.first);
      if (user.isBanned) {
        await logout();
        throw AuthException('Akun Anda telah dinonaktifkan');
      }

      _currentUser = user;
      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      await logout();
      return null;
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) throw AuthException('Belum login');

    final updates = <String>[];
    final params = <dynamic>[];

    if (fullName != null) {
      updates.add('full_name = ?');
      params.add(fullName);
    }
    if (phone != null) {
      updates.add('phone = ?');
      params.add(phone);
    }
    if (avatarUrl != null) {
      updates.add('avatar_url = ?');
      params.add(avatarUrl);
    }

    if (updates.isEmpty) return _currentUser!;

    params.add(_currentUser!.id);
    await _db.execute(
      'UPDATE users SET ${updates.join(', ')} WHERE id = ?',
      params,
    );

    _currentUser = _currentUser!.copyWith(
      fullName: fullName ?? _currentUser!.fullName,
      phone: phone ?? _currentUser!.phone,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
    );

    await _db.sync();
    return _currentUser!;
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) throw AuthException('Belum login');

    final currentHash = _hashPassword(currentPassword);
    final results = await _db.query(
      'SELECT id FROM users WHERE id = ? AND password_hash = ?',
      [_currentUser!.id, currentHash],
    );

    if (results.isEmpty) {
      throw AuthException('Password lama salah');
    }

    final newHash = _hashPassword(newPassword);
    await _db.execute(
      'UPDATE users SET password_hash = ? WHERE id = ?',
      [newHash, _currentUser!.id],
    );

    await _db.sync();
  }

  /// Save session to secure storage
  Future<void> _saveSession(UserModel user) async {
    final token = _generateToken(user.id);
    await _sessionStorage.write(key: _tokenKey, value: token);
    await _sessionStorage.write(key: _userIdKey, value: user.id);
  }
}

/// Narrow storage boundary so authentication behavior can be tested locally.
abstract class AuthSessionStorage {
  Future<String?> read(String key);
  Future<void> write({required String key, required String value});
  Future<void> delete(String key);
}

class SecureAuthSessionStorage implements AuthSessionStorage {
  final FlutterSecureStorage _storage;

  SecureAuthSessionStorage(FlutterSecureStorage? storage)
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }
}

/// Sanitized identity data required to map an authenticated Google account.
class GoogleAccount {
  final String email;
  final String? displayName;
  final String? photoUrl;

  const GoogleAccount({
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

abstract class GoogleSignInClient {
  Future<GoogleAccount?> signIn();
}

class GoogleSignInClientImpl implements GoogleSignInClient {
  final GoogleSignIn _client;

  GoogleSignInClientImpl({GoogleSignIn? client})
      : _client = client ?? GoogleSignIn();

  @override
  Future<GoogleAccount?> signIn() async {
    final account = await _client.signIn();
    if (account == null) return null;

    return GoogleAccount(
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
  }
}

/// Custom auth exception
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
