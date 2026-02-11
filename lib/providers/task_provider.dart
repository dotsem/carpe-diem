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
  List<Task> _unscheduledTasks = [];
  bool _isLoading = false;
  DateTime _currentDate = DateTime.now();

  List<Task> get tasks => _tasks;
  List<Task> get overdueTasks => _overdueTasks;
  List<Task> get unscheduledTasks => _unscheduledTasks;
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

  Future<void> loadUnscheduledTasks() async {
    _isLoading = true;
    notifyListeners();

    _unscheduledTasks = await _repo.getUnscheduled();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? scheduledDate,
    String? projectId,
    Priority priority = Priority.none,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      scheduledDate: scheduledDate != null ? _normalizeDate(scheduledDate) : null,
      projectId: projectId,
      priority: priority,
      createdAt: DateTime.now(),
    );
    await _repo.insert(task);
    await loadTasksForDate(_currentDate);
    await loadUnscheduledTasks();
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _repo.update(updated);
    await _refreshAll();
  }

  Future<void> updateTask(Task task) async {
    await _repo.update(task);
    await _refreshAll();
  }

  Future<void> deleteTask(Task task) async {
    await _repo.delete(task.id);
    await _refreshAll();
  }

  Future<void> rescheduleOverdue(Task task, DateTime newDate) async {
    final updated = task.copyWith(scheduledDate: _normalizeDate(newDate));
    await _repo.update(updated);
    await _refreshAll();
  }

  Future<List<Task>> getTasksForProject(String projectId) async {
    return _repo.getByProject(projectId);
  }

  Future<List<Task>> getBacklog() async {
    return _repo.getUnscheduled();
  }

  Future<void> _refreshAll() async {
    await loadTasksForDate(_currentDate);
    await loadUnscheduledTasks();
  }

  Future<void> scheduleTasksForToday(List<String> taskIds) async {
    final today = _normalizeDate(DateTime.now());
    for (final id in taskIds) {
      final task = _tasks.firstWhere((t) => t.id == id, orElse: () => _unscheduledTasks.firstWhere((t) => t.id == id));
      final updated = task.copyWith(scheduledDate: today);
      await _repo.update(updated);
    }
    await _refreshAll();
  }

  Future<void> importTasksFromMarkdown(String markdown, String? projectId) async {
    final tasks = _parseMarkdown(markdown);
    for (final task in tasks) {
      await _repo.insert(task.copyWith(projectId: projectId));
    }
    await _refreshAll();
  }

  List<Task> _parseMarkdown(String markdown) {
    final tasks = <Task>[];
    final lines = markdown.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if ((trimmed.startsWith('- [ ]') || trimmed.startsWith('- ')) && !trimmed.startsWith('- [x]')) {
        final match = RegExp(r'^- \[?(x|\s)?\]?\s+(.*)$').firstMatch(trimmed);
        if (match != null) {
          final isCompleted = match.group(1) == 'x';
          final title = match.group(2)!.trim();
          tasks.add(Task(id: _uuid.v4(), title: title, isCompleted: isCompleted, createdAt: DateTime.now()));
        }
      }
    }
    return tasks;
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);
}
