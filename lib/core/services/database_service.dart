import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../utils/constants.dart';

/// SQLite database service for local storage
class DatabaseService extends GetxService {
  static DatabaseService get to => Get.find<DatabaseService>();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final dbFilePath = path.join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      dbFilePath,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableUsers} (
        id TEXT PRIMARY KEY,
        email TEXT,
        phone TEXT,
        display_name TEXT NOT NULL,
        avatar_url TEXT,
        language TEXT DEFAULT 'en',
        is_premium INTEGER DEFAULT 0,
        premium_until TEXT,
        referral_code TEXT,
        created_at TEXT NOT NULL,
        last_active TEXT NOT NULL
      )
    ''');

    // Habits table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableHabits} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        custom_days TEXT,
        target_count INTEGER,
        reminder_time TEXT,
        reminder_enabled INTEGER DEFAULT 1,
        color INTEGER NOT NULL,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        archived_at TEXT
      )
    ''');

    // Check-ins table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCheckIns} (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        check_in_date TEXT NOT NULL,
        check_in_time TEXT NOT NULL,
        count INTEGER DEFAULT 1,
        notes TEXT,
        mood TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES ${AppConstants.tableHabits}(id) ON DELETE CASCADE,
        UNIQUE(habit_id, check_in_date)
      )
    ''');

    // Create indexes for performance
    await db.execute('''
      CREATE INDEX idx_habit_active ON ${AppConstants.tableHabits}(is_active)
    ''');
    await db.execute('''
      CREATE INDEX idx_checkin_habit_date ON ${AppConstants.tableCheckIns}(habit_id, check_in_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_checkin_date ON ${AppConstants.tableCheckIns}(check_in_date)
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here in future versions
  }

  /// Insert a record
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Update a record
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// Delete a record
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Query records
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Raw query
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
