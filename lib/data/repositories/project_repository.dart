import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:carpe_diem/data/database/database_helper.dart';
import 'package:carpe_diem/data/models/project.dart';

class ProjectRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<Project>> getAll() async {
    final db = await _db;
    final maps = await db.query('projects', orderBy: 'priority DESC, name ASC');
    return maps.map(Project.fromMap).toList();
  }

  Future<Project?> getById(String id) async {
    final db = await _db;
    final maps = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Project.fromMap(maps.first);
  }

  Future<void> insert(Project project) async {
    final db = await _db;
    await db.insert('projects', project.toMap());
  }

  Future<void> update(Project project) async {
    final db = await _db;
    await db.update('projects', project.toMap(), where: 'id = ?', whereArgs: [project.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }
}
