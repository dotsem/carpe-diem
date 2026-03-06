import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:carpe_diem/data/database/database_helper.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/task_status.dart';

class TaskRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<Task>> getAll() async {
    final db = await _db;
    final maps = await db.query('tasks', orderBy: '(deadline IS NULL), deadline ASC, priority DESC, createdAt DESC');

    List<Task> tasks = [];
    for (final map in maps) {
      final id = map['id'] as String;
      final labelIds = await _getLabelIds(id);
      tasks.add(Task.fromMap(map, labelIds: labelIds));
    }
    return tasks;
  }

  Future<Task?> getById(String id) async {
    final db = await _db;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    final labelIds = await _getLabelIds(id);
    return Task.fromMap(maps.first, labelIds: labelIds);
  }

  Future<List<Task>> getByDate(DateTime date) async {
    final db = await _db;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final scheduledDateStr = startOfDay.toIso8601String();

    final maps = await db.query(
      'tasks',
      where: '(scheduledDate = ?) OR (completedAt >= ? AND completedAt < ?)',
      whereArgs: [scheduledDateStr, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: '(deadline IS NULL), deadline ASC, priority DESC, createdAt DESC',
    );

    List<Task> tasks = [];
    for (final map in maps) {
      final id = map['id'] as String;
      final labelIds = await _getLabelIds(id);
      tasks.add(Task.fromMap(map, labelIds: labelIds));
    }
    return tasks;
  }

  Future<List<Task>> getOverdue(DateTime today) async {
    final db = await _db;
    final dateStr = DateTime(today.year, today.month, today.day).toIso8601String();
    final maps = await db.query(
      'tasks',
      where: 'scheduledDate IS NOT NULL AND scheduledDate < ? AND status != ?',
      whereArgs: [dateStr, TaskStatus.done.index],
      orderBy: 'priority DESC, scheduledDate ASC',
    );

    List<Task> tasks = [];
    for (final map in maps) {
      final id = map['id'] as String;
      final labelIds = await _getLabelIds(id);
      tasks.add(Task.fromMap(map, labelIds: labelIds));
    }
    return tasks;
  }

  Future<List<Task>> getUnscheduled() async {
    final db = await _db;
    final maps = await db.query(
      'tasks',
      where: 'scheduledDate IS NULL',
      orderBy: '(deadline IS NULL), deadline ASC, priority DESC, createdAt DESC',
    );

    List<Task> tasks = [];
    for (final map in maps) {
      final id = map['id'] as String;
      final labelIds = await _getLabelIds(id);
      tasks.add(Task.fromMap(map, labelIds: labelIds));
    }
    return tasks;
  }

  Future<List<Task>> getByProject(String projectId) async {
    final db = await _db;
    final maps = await db.query(
      'tasks',
      where: 'projectId = ?',
      whereArgs: [projectId],
      orderBy: '(deadline IS NULL), deadline ASC, priority DESC, scheduledDate ASC',
    );

    List<Task> tasks = [];
    for (final map in maps) {
      final id = map['id'] as String;
      final labelIds = await _getLabelIds(id);
      tasks.add(Task.fromMap(map, labelIds: labelIds));
    }
    return tasks;
  }

  Future<List<Task>> getByLabel(String labelId) async {
    final db = await _db;
    final maps = await db.rawQuery(
      '''
      SELECT DISTINCT t.* FROM tasks t
      LEFT JOIN project_labels pl ON t.projectId = pl.projectId
      LEFT JOIN task_labels tl ON t.id = tl.taskId
      WHERE pl.labelId = ? OR tl.labelId = ?
      ORDER BY (t.deadline IS NULL), t.deadline ASC, t.priority DESC, t.scheduledDate ASC
    ''',
      [labelId, labelId],
    );

    List<Task> tasks = [];
    for (final map in maps) {
      final id = map['id'] as String;
      final labelIds = await _getLabelIds(id);
      tasks.add(Task.fromMap(map, labelIds: labelIds));
    }
    return tasks;
  }

  Future<void> insert(Task task) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert('tasks', task.toMap());
      for (final labelId in task.labelIds) {
        await txn.insert('task_labels', {'taskId': task.id, 'labelId': labelId});
      }
    });
  }

  Future<void> update(Task task) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);

      await txn.delete('task_labels', where: 'taskId = ?', whereArgs: [task.id]);
      for (final labelId in task.labelIds) {
        await txn.insert('task_labels', {'taskId': task.id, 'labelId': labelId});
      }
    });
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> _getLabelIds(String taskId) async {
    final db = await _db;
    final maps = await db.query('task_labels', where: 'taskId = ?', columns: ['labelId'], whereArgs: [taskId]);
    return maps.map((m) => m['labelId'] as String).toList();
  }
}
