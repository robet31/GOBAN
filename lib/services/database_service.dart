import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Local SQLite database service singleton.
class DatabaseService {
  static DatabaseService? _instance;
  DatabaseFactory? _databaseFactory;
  String? _databasePath;
  Database? _database;
  bool _isInitialized = false;

  DatabaseService._({DatabaseFactory? databaseFactory, String? databasePath})
      : _databaseFactory = databaseFactory,
        _databasePath = databasePath;

  @visibleForTesting
  factory DatabaseService.forTesting(DatabaseFactory databaseFactory) {
    return DatabaseService._(
      databaseFactory: databaseFactory,
      databasePath: ':memory:',
    );
  }

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  bool get isInitialized => _isInitialized;

  /// Opens durable native storage or the browser SQLite-WASM database.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _databaseFactory ??= kIsWeb ? databaseFactoryFfiWeb : databaseFactory;
    _databasePath ??=
        kIsWeb ? 'goban.db' : '${await getDatabasesPath()}/goban.db';
    _database = await _databaseFactory!.openDatabase(_databasePath!);
    await _runMigrations();
    _isInitialized = true;
  }

  /// Run database schema migrations
  Future<void> _runMigrations() async {
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('customer','technician','admin')),
        password_hash TEXT NOT NULL,
        avatar_url TEXT,
        is_banned INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS technician_profiles (
        id TEXT PRIMARY KEY REFERENCES users(id),
        shop_name TEXT,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        address TEXT,
        services TEXT NOT NULL DEFAULT '[]',
        price_estimate INTEGER,
        is_online INTEGER DEFAULT 0,
        is_verified INTEGER DEFAULT 0,
        ktp_url TEXT,
        sim_url TEXT,
        stnk_url TEXT,
        shop_photo_url TEXT,
        rating_avg REAL DEFAULT 0,
        total_orders INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        lat REAL NOT NULL,
        lng REAL NOT NULL,
        category TEXT NOT NULL CHECK (category IN ('tambal_ban','service_motor','kedua')),
        address TEXT,
        phone TEXT,
        photo_url TEXT,
        added_by TEXT NOT NULL REFERENCES users(id),
        status TEXT DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL REFERENCES users(id),
        technician_id TEXT REFERENCES users(id),
        service_type TEXT NOT NULL,
        description TEXT,
        status TEXT DEFAULT 'waiting' CHECK (status IN ('waiting','accepted','ongoing','completed','cancelled')),
        customer_lat REAL NOT NULL,
        customer_lng REAL NOT NULL,
        customer_address TEXT,
        price INTEGER,
        payment_method TEXT CHECK (payment_method IN ('cash','transfer')),
        distance_km REAL,
        created_at TEXT DEFAULT (datetime('now')),
        accepted_at TEXT,
        completed_at TEXT
      )
    ''');

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL REFERENCES orders(id) UNIQUE,
        reviewer_id TEXT NOT NULL REFERENCES users(id),
        rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
        comment TEXT,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL REFERENCES users(id),
        title TEXT NOT NULL,
        body TEXT,
        data TEXT,
        read INTEGER DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS chats (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL REFERENCES orders(id),
        sender_id TEXT NOT NULL REFERENCES users(id),
        message TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    // Create indexes
    await _database!.execute(
      'CREATE INDEX IF NOT EXISTS idx_tech_online ON technician_profiles (is_online, is_verified)',
    );
    await _database!.execute(
      'CREATE INDEX IF NOT EXISTS idx_locations_status ON locations (status)',
    );
    await _database!.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders (customer_id, status)',
    );
    await _database!.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_technician ON orders (technician_id, status)',
    );
    await _database!.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_created ON orders (created_at)',
    );
    await _database!.execute(
      'CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications (user_id, read)',
    );
    await _database!.execute(
      'CREATE INDEX IF NOT EXISTS idx_chats_order ON chats (order_id, created_at)',
    );
  }

  /// Execute a raw SQL query and return results as List<Map>
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? params,
  ]) async {
    return _database!.rawQuery(sql, params);
  }

  /// Execute a write SQL statement
  Future<void> execute(String sql, [List<dynamic>? params]) async {
    await _database!.execute(sql, params);
  }

  /// Retained for existing callers. Local SQLite has no remote sync endpoint.
  Future<void> sync() async {
    return;
  }

  /// Close the database connection
  Future<void> close() async {
    await _database?.close();
    _database = null;
    _isInitialized = false;
  }
}
