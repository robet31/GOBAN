import 'package:flutter_test/flutter_test.dart';
import 'package:goban/services/auth_service.dart';
import 'package:goban/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('maps a Google account to a local user and updates its avatar',
      () async {
    final database = DatabaseService.forTesting(databaseFactoryFfi);
    await database.initialize();
    final sessions = _MemorySessionStorage();
    final auth = AuthService(
      db: database,
      sessionStorage: sessions,
      googleSignIn: _FakeGoogleSignIn(
        const GoogleAccount(
          email: 'customer@example.com',
          displayName: 'Google Customer',
          photoUrl: 'https://example.com/customer.jpg',
        ),
      ),
    );

    final created = await auth.loginWithGoogle();
    final createdRows = await database.query(
      'SELECT password_hash, avatar_url FROM users WHERE id = ?',
      [created!.id],
    );

    expect(created.email, 'customer@example.com');
    expect(created.fullName, 'Google Customer');
    expect(created.avatarUrl, 'https://example.com/customer.jpg');
    expect(created.role.name, 'customer');
    expect(createdRows.single['password_hash'], isNotEmpty);
    expect(
        createdRows.single['avatar_url'], 'https://example.com/customer.jpg');
    expect(sessions.values['user_id'], created.id);

    await database.execute(
      'UPDATE users SET full_name = ?, avatar_url = NULL WHERE id = ?',
      ['Local Customer', created.id],
    );
    final mapped = await auth.loginWithGoogle();

    expect(mapped!.id, created.id);
    expect(mapped.fullName, 'Local Customer');
    expect(mapped.avatarUrl, 'https://example.com/customer.jpg');

    await database.close();
  });
}

class _FakeGoogleSignIn implements GoogleSignInClient {
  final GoogleAccount? account;

  _FakeGoogleSignIn(this.account);

  @override
  Future<GoogleAccount?> signIn() async => account;
}

class _MemorySessionStorage implements AuthSessionStorage {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }
}
