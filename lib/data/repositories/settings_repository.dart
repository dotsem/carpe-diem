import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:carpe_diem/data/database/database_helper.dart';

class SettingsRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<void> set(String key, String value) async {
    final db = await _db;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> get(String key) async {
    final db = await _db;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<Map<String, String>> getAll() async {
    final db = await _db;
    final maps = await db.query('settings');
    return {for (var map in maps) map['key'] as String: map['value'] as String};
  }
}
