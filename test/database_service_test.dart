import 'package:flutter_test/flutter_test.dart';
import 'package:goban/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('initializes the local schema and preserves the database facade',
      () async {
    final service = DatabaseService.forTesting(databaseFactoryFfi);

    await service.initialize();
    await service.execute(
      '''INSERT INTO users (id, email, full_name, role, password_hash)
         VALUES (?, ?, ?, ?, ?)''',
      ['user-1', 'user@example.com', 'User One', 'customer', 'hash'],
    );

    final users = await service.query(
      'SELECT email FROM users WHERE id = ?',
      ['user-1'],
    );
    await service.sync();

    expect(users, [
      {'email': 'user@example.com'},
    ]);
    expect(service.isInitialized, isTrue);
  });
}
