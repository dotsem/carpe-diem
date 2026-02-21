import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/project.dart';
import 'package:carpe_diem/ui/widgets/chip/small_chip.dart';
import 'package:flutter/material.dart';

class OverdueChip extends StatelessWidget {
  const OverdueChip({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallChip(
      color: AppColors.error.withValues(alpha: 0.2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_off_outlined, size: 10, color: AppColors.error),
          const SizedBox(width: 4),
          const Text('Overdue', style: TextStyle(fontSize: 11, color: AppColors.error)),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallChip(
      color: AppColors.accent.withValues(alpha: 0.2),
      child: const Text('In Progress', style: TextStyle(fontSize: 11, color: AppColors.accent)),
    );
  }
}

class ProjectChip extends StatelessWidget {
  final Project? project;

  const ProjectChip({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return SmallChip(
      color: project!.color,
      child: Text(project!.name, style: TextStyle(fontSize: 11, color: AppColors.text)),
    );
  }
}

class DeadlineChip extends StatelessWidget {
  final DateTime deadline;

  const DeadlineChip({super.key, required this.deadline});

  static const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    return SmallChip(
      color: AppColors.textSecondary.withValues(alpha: 0.1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 10, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            'Due: ${months[deadline.month - 1]} ${deadline.day}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
