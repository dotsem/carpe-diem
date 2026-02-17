import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:carpe_diem/core/constants/app_constants.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<void> initialize() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  static Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, AppConstants.dbName);

    return openDatabase(path, version: AppConstants.dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        color INTEGER NOT NULL,
        priority INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE labels (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE project_labels (
        projectId TEXT NOT NULL,
        labelId TEXT NOT NULL,
        PRIMARY KEY (projectId, labelId),
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (labelId) REFERENCES labels(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        scheduledDate TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        projectId TEXT,
        priority INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        completedAt TEXT,
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await _migrateToV5(db);
    }
  }

  static Future<void> _migrateToV5(Database db) async {
    // Check if completedAt column exists
    final List<Map<String, dynamic>> columns = await db.rawQuery('PRAGMA table_info(tasks)');
    final hasCompletedAt = columns.any((column) => column['name'] == 'completedAt');

    if (!hasCompletedAt) {
      await db.execute('ALTER TABLE tasks ADD COLUMN completedAt TEXT');
    }
  }
}
