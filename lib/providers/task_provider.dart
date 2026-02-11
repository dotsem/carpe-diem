import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/priority.dart';
import 'package:carpe_diem/data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repo = TaskRepository();
  final _uuid = const Uuid();

  List<Task> _tasks = [];
  List<Task> _overdueTasks = [];
  bool _isLoading = false;
  DateTime _currentDate = DateTime.now();

  List<Task> get tasks => _tasks;
  List<Task> get overdueTasks => _overdueTasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasksForDate(DateTime date) async {
    _isLoading = true;
    _currentDate = _normalizeDate(date);
    notifyListeners();

    _tasks = await _repo.getByDate(_currentDate);
    _overdueTasks = await _repo.getOverdue(_currentDate);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? description,
    required DateTime scheduledDate,
    String? projectId,
    Priority priority = Priority.none,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      scheduledDate: _normalizeDate(scheduledDate),
      projectId: projectId,
      priority: priority,
      createdAt: DateTime.now(),
    );
    await _repo.insert(task);
    await loadTasksForDate(scheduledDate);
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _repo.update(updated);
    await loadTasksForDate(_currentDate);
  }

  Future<void> updateTask(Task task) async {
    await _repo.update(task);
    await loadTasksForDate(_currentDate);
  }

  Future<void> deleteTask(Task task) async {
    await _repo.delete(task.id);
    await loadTasksForDate(_currentDate);
  }

  Future<void> rescheduleOverdue(Task task, DateTime newDate) async {
    final updated = task.copyWith(scheduledDate: _normalizeDate(newDate));
    await _repo.update(updated);
    await loadTasksForDate(_currentDate);
  }

  Future<List<Task>> getTasksForProject(String projectId) async {
    return _repo.getByProject(projectId);
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);
}
