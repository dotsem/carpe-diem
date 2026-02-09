import 'package:flutter/material.dart';
import 'package:carpe_diem/data/models/priority.dart';

class Project {
  final String id;
  final String name;
  final String? description;
  final Color color;
  final Priority priority;
  final DateTime createdAt;

  const Project({required this.id, required this.name, this.description, required this.color, this.priority = Priority.none, required this.createdAt});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'description': description, 'color': color.toARGB32(), 'priority': priority.index, 'createdAt': createdAt.toIso8601String()};

  factory Project.fromMap(Map<String, dynamic> map) => Project(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String?,
    color: Color(map['color'] as int),
    priority: Priority.values[map['priority'] as int],
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  Project copyWith({String? name, String? description, Color? color, Priority? priority}) =>
      Project(id: id, name: name ?? this.name, description: description ?? this.description, color: color ?? this.color, priority: priority ?? this.priority, createdAt: createdAt);
}
