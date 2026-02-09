import 'package:flutter/material.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/project.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Project? project;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isOverdue;

  const TaskCard({super.key, required this.task, this.project, required this.onToggle, required this.onTap, this.onDelete, this.isOverdue = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _priorityIndicator(),
              const SizedBox(width: 8),
              Checkbox(value: task.isCompleted, onChanged: (_) => onToggle()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, decoration: task.isCompleted ? TextDecoration.lineThrough : null, color: task.isCompleted ? AppColors.textSecondary : AppColors.text),
                    ),
                    if (task.description != null && task.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          task.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    if (project != null || isOverdue) ...[
                      const SizedBox(height: 4),
                      Row(children: [if (project != null) _projectChip(), if (isOverdue) _overdueChip()]),
                    ],
                  ],
                ),
              ),
              if (onDelete != null) IconButton(icon: const Icon(Icons.close, size: 18), color: AppColors.textSecondary, onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityIndicator() {
    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(color: task.priority.color, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _projectChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(color: project!.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(project!.name, style: TextStyle(fontSize: 11, color: project!.color)),
    );
  }

  Widget _overdueChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
      child: const Text('Overdue', style: TextStyle(fontSize: 11, color: AppColors.error)),
    );
  }
}
