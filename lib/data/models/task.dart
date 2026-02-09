import 'package:carpe_diem/data/models/priority.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime scheduledDate;
  final bool isCompleted;
  final String? projectId;
  final Priority priority;
  final DateTime createdAt;

  const Task({required this.id, required this.title, this.description, required this.scheduledDate, this.isCompleted = false, this.projectId, this.priority = Priority.none, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'scheduledDate': scheduledDate.toIso8601String(),
    'isCompleted': isCompleted ? 1 : 0,
    'projectId': projectId,
    'priority': priority.index,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    scheduledDate: DateTime.parse(map['scheduledDate'] as String),
    isCompleted: (map['isCompleted'] as int) == 1,
    projectId: map['projectId'] as String?,
    priority: Priority.values[map['priority'] as int],
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  Task copyWith({String? title, String? description, DateTime? scheduledDate, bool? isCompleted, String? projectId, Priority? priority}) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    isCompleted: isCompleted ?? this.isCompleted,
    projectId: projectId ?? this.projectId,
    priority: priority ?? this.priority,
    createdAt: createdAt,
  );
}
