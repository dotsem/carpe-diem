import 'package:carpe_diem/data/models/label.dart';
import 'package:carpe_diem/data/repositories/project_repository.dart';
import 'package:carpe_diem/providers/label_provider.dart';
import 'package:carpe_diem/ui/widgets/context_menu/label_chip.dart';
import 'package:flutter/material.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/project.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Project? project;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isOverdue;
  final bool selectionMode;
  final bool isSelected;
  final void Function(Offset localPosition, RenderBox renderBox)? onContextMenu;

  const TaskCard({
    super.key,
    required this.task,
    this.project,
    required this.onToggle,
    required this.onTap,
    this.trailing,
    this.isOverdue = false,
    this.selectionMode = false,
    this.isSelected = false,
    this.onContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        onSecondaryTapDown: onContextMenu != null
            ? (details) => onContextMenu!(details.localPosition, context.findRenderObject() as RenderBox)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: project?.color != null
                ? LinearGradient(
                    colors: [AppColors.surface, project!.color],
                    begin: Alignment.center,
                    end: Alignment.centerRight,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _priorityIndicator(),
                const SizedBox(width: 8),
                Checkbox(value: selectionMode ? isSelected : task.isCompleted, onChanged: (_) => onToggle()),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: (!selectionMode && task.isCompleted) ? TextDecoration.lineThrough : null,
                          color: (task.isCompleted && !selectionMode) ? AppColors.textSecondary : AppColors.text,
                        ),
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
                        Row(
                          children: [
                            if (isOverdue) _overdueChip(),
                            if (project != null) _projectChip(),
                            if (project != null) ..._getLabels(context),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _priorityIndicator() {
    return Container(
      width: 6,
      height: 40,
      decoration: BoxDecoration(color: task.priority.color, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _projectChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(color: project!.color.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(4)),
      child: Text(project!.name, style: TextStyle(fontSize: 11, color: AppColors.text)),
    );
  }

  Widget _overdueChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
      child: const Text('Overdue', style: TextStyle(fontSize: 11, color: AppColors.error)),
    );
  }

  List<Widget> _getLabels(BuildContext context) {
    final labelProvider = context.watch<LabelProvider>();
    final labels = project!.labelIds.map((id) => labelProvider.getById(id)).whereType<Label>().toList();

    return labels.map((label) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: LabelChip(label: label),
      );
    }).toList();
  }
}
