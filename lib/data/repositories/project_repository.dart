import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:carpe_diem/data/database/database_helper.dart';
import 'package:carpe_diem/data/models/project.dart';

class ProjectRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<Project>> getAll() async {
    final db = await _db;
    final maps = await db.query('projects', orderBy: '(deadline IS NULL), deadline ASC, priority DESC, name ASC');

    List<Project> projects = [];
    for (final map in maps) {
      final id = map['id'] as String;
      final labelIds = await _getLabelIds(id);
      projects.add(Project.fromMap(map, labelIds: labelIds));
    }
    return projects;
  }

  Future<Project?> getById(String id) async {
    final db = await _db;
    final maps = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    final labelIds = await _getLabelIds(id);
    return Project.fromMap(maps.first, labelIds: labelIds);
  }

  Future<void> insert(Project project) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert('projects', project.toMap());
      for (final labelId in project.labelIds) {
        await txn.insert('project_labels', {'projectId': project.id, 'labelId': labelId});
      }
    });
  }

  Future<void> update(Project project) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update('projects', project.toMap(), where: 'id = ?', whereArgs: [project.id]);

      // Update labels: simplest is to delete all and re-insert
      await txn.delete('project_labels', where: 'projectId = ?', whereArgs: [project.id]);
      for (final labelId in project.labelIds) {
        await txn.insert('project_labels', {'projectId': project.id, 'labelId': labelId});
      }
    });
  }

  Future<void> delete(String id) async {
    final db = await _db;
    // project_labels will be deleted via CASCADE
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> _getLabelIds(String projectId) async {
    final db = await _db;
    final maps = await db.query('project_labels', where: 'projectId = ?', columns: ['labelId'], whereArgs: [projectId]);
    return maps.map((m) => m['labelId'] as String).toList();
  }
}
