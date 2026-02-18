import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:carpe_diem/data/database/database_helper.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/task_status.dart';

class TaskRepository {
  Future<Database> get _db => DatabaseHelper.database;

  Future<List<Task>> getAll() async {
    final db = await _db;
    final maps = await db.query('tasks', orderBy: '(deadline IS NULL), deadline ASC, priority DESC, createdAt DESC');
    return maps.map(Task.fromMap).toList();
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
    return maps.map(Task.fromMap).toList();
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
    return maps.map(Task.fromMap).toList();
  }

  Future<List<Task>> getUnscheduled() async {
    final db = await _db;
    final maps = await db.query(
      'tasks',
      where: 'scheduledDate IS NULL',
      orderBy: '(deadline IS NULL), deadline ASC, priority DESC, createdAt DESC',
    );
    return maps.map(Task.fromMap).toList();
  }

  Future<List<Task>> getByProject(String projectId) async {
    final db = await _db;
    final maps = await db.query(
      'tasks',
      where: 'projectId = ?',
      whereArgs: [projectId],
      orderBy: '(deadline IS NULL), deadline ASC, priority DESC, scheduledDate ASC',
    );
    return maps.map(Task.fromMap).toList();
  }

  Future<List<Task>> getByLabel(String labelId) async {
    final db = await _db;
    final maps = await db.rawQuery(
      '''
      SELECT t.* FROM tasks t
      INNER JOIN project_labels pl ON t.projectId = pl.projectId
      WHERE pl.labelId = ?
      ORDER BY (t.deadline IS NULL), t.deadline ASC, t.priority DESC, t.scheduledDate ASC
    ''',
      [labelId],
    );
    return maps.map(Task.fromMap).toList();
  }

  Future<void> insert(Task task) async {
    final db = await _db;
    await db.insert('tasks', task.toMap());
  }

  Future<void> update(Task task) async {
    final db = await _db;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
