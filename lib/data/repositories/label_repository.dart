import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:carpe_diem/data/database/database_helper.dart';
import 'package:carpe_diem/data/models/label.dart';

class LabelRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<Label>> getAll() async {
    final db = await _db;
    final maps = await db.query('labels', orderBy: 'name ASC');
    return maps.map(Label.fromMap).toList();
  }

  Future<Label?> getById(String id) async {
    final db = await _db;
    final maps = await db.query('labels', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Label.fromMap(maps.first);
  }

  Future<void> insert(Label label) async {
    final db = await _db;
    await db.insert('labels', label.toMap());
  }

  Future<void> update(Label label) async {
    final db = await _db;
    await db.update('labels', label.toMap(), where: 'id = ?', whereArgs: [label.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('labels', where: 'id = ?', whereArgs: [id]);
  }
}
