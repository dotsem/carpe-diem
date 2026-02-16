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
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await _migrateToV4(db);
    }
  }

  static Future<void> _migrateToV4(Database db) async {
    // Create the junction table if it doesn't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS project_labels (
        projectId TEXT NOT NULL,
        labelId TEXT NOT NULL,
        PRIMARY KEY (projectId, labelId),
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE,
        FOREIGN KEY (labelId) REFERENCES labels(id) ON DELETE CASCADE
      )
    ''');

    // Move existing labelIds to the junction table if the column still exists
    try {
      final List<Map<String, dynamic>> columns = await db.rawQuery('PRAGMA table_info(projects)');
      final hasLabelId = columns.any((column) => column['name'] == 'labelId');

      if (hasLabelId) {
        final List<Map<String, dynamic>> projects = await db.query('projects', columns: ['id', 'labelId']);
        for (final project in projects) {
          final projectId = project['id'] as String;
          final labelId = project['labelId'] as String?;
          if (labelId != null) {
            // Use insert ignore or check existence to avoid duplicates if re-running
            await db.insert('project_labels', {
              'projectId': projectId,
              'labelId': labelId,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
      }
    } catch (e) {
      // Ignore errors during data migration, we'll try to proceed with schema change
    }

    // Since SQLite ALTER TABLE DROP COLUMN is not always available,
    // we use the pattern: create new table, copy data, drop old, rename
    // First, check if labelId column exists. If it doesn't, we might have already done this.
    final List<Map<String, dynamic>> columns = await db.rawQuery('PRAGMA table_info(projects)');
    final hasLabelId = columns.any((column) => column['name'] == 'labelId');

    if (hasLabelId) {
      await db.execute('DROP TABLE IF EXISTS projects_new');
      await db.execute('''
        CREATE TABLE projects_new (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          color INTEGER NOT NULL,
          priority INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        INSERT INTO projects_new (id, name, description, color, priority, createdAt)
        SELECT id, name, description, color, priority, createdAt FROM projects
      ''');

      await db.execute('DROP TABLE projects');
      await db.execute('ALTER TABLE projects_new RENAME TO projects');
    }
  }
}
