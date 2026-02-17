import 'package:carpe_diem/data/models/priority.dart';
import 'package:carpe_diem/data/models/task_status.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? scheduledDate;
  final TaskStatus status;
  final String? projectId;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isCompleted => status.isDone;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.scheduledDate,
    this.status = TaskStatus.todo,
    this.projectId,
    this.priority = Priority.none,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'scheduledDate': scheduledDate?.toIso8601String(),
    'isCompleted': isCompleted ? 1 : 0,
    'status': status.index,
    'projectId': projectId,
    'priority': priority.index,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    scheduledDate: map['scheduledDate'] != null ? DateTime.parse(map['scheduledDate'] as String) : null,
    status: TaskStatus.values[map['status'] as int],
    projectId: map['projectId'] as String?,
    priority: Priority.values[map['priority'] as int],
    createdAt: DateTime.parse(map['createdAt'] as String),
    completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
  );

  Task copyWith({
    String? title,
    String? description,
    DateTime? scheduledDate,
    bool clearScheduledDate = false,
    TaskStatus? status,
    String? projectId,
    Priority? priority,
    DateTime? completedAt,
  }) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    scheduledDate: clearScheduledDate ? null : (scheduledDate ?? this.scheduledDate),
    status: status ?? this.status,
    projectId: projectId ?? this.projectId,
    priority: priority ?? this.priority,
    createdAt: createdAt,
    completedAt: status == TaskStatus.done
        ? (completedAt ?? DateTime.now())
        : (status != null && !status.isDone ? null : this.completedAt),
  );
}
