import 'package:flutter/material.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/task_status.dart';
import 'package:carpe_diem/providers/project_provider.dart';

class KanbanBoard extends StatelessWidget {
  final List<Task> tasks;
  final ProjectProvider projectProvider;
  final void Function(Task task, TaskStatus status) onStatusChange;
  final void Function(Task task, Offset localPosition, RenderBox renderBox) onContextMenu;
  final void Function(Task task) onEdit;

  const KanbanBoard({
    super.key,
    required this.tasks,
    required this.projectProvider,
    required this.onStatusChange,
    required this.onContextMenu,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final todo = tasks.where((t) => t.status.isTodo).toList();
    final inProgress = tasks.where((t) => t.status.isInProgress).toList();
    final done = tasks.where((t) => t.status.isDone).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KanbanColumn(
            title: 'Todo',
            titleColor: AppColors.text,
            tasks: todo,
            acceptedStatus: TaskStatus.todo,
            projectProvider: projectProvider,
            onStatusChange: onStatusChange,
            onContextMenu: onContextMenu,
            onEdit: onEdit,
          ),
          const SizedBox(width: 16),
          _KanbanColumn(
            title: 'In Progress',
            titleColor: AppColors.accent,
            tasks: inProgress,
            acceptedStatus: TaskStatus.inProgress,
            projectProvider: projectProvider,
            onStatusChange: onStatusChange,
            onContextMenu: onContextMenu,
            onEdit: onEdit,
          ),
          const SizedBox(width: 16),
          _KanbanColumn(
            title: 'Done',
            titleColor: AppColors.success,
            tasks: done,
            acceptedStatus: TaskStatus.done,
            projectProvider: projectProvider,
            onStatusChange: onStatusChange,
            onContextMenu: onContextMenu,
            onEdit: onEdit,
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<Task> tasks;
  final TaskStatus acceptedStatus;
  final ProjectProvider projectProvider;
  final void Function(Task task, TaskStatus status) onStatusChange;
  final void Function(Task task, Offset localPosition, RenderBox renderBox) onContextMenu;
  final void Function(Task task) onEdit;

  const _KanbanColumn({
    required this.title,
    required this.titleColor,
    required this.tasks,
    required this.acceptedStatus,
    required this.projectProvider,
    required this.onStatusChange,
    required this.onContextMenu,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DragTarget<Task>(
        onWillAcceptWithDetails: (details) => details.data.status != acceptedStatus,
        onAcceptWithDetails: (details) => onStatusChange(details.data, acceptedStatus),
        builder: (context, candidateData, rejectedData) {
          final isHighlighted = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isHighlighted ? titleColor.withValues(alpha: 0.1) : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighlighted ? titleColor.withValues(alpha: 0.4) : AppColors.surfaceLight,
                width: isHighlighted ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: titleColor),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: titleColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${tasks.length}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: titleColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Drop tasks here',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) => _KanbanCard(
                            key: ValueKey(tasks[index].id),
                            task: tasks[index],
                            project: projectProvider,
                            onContextMenu: onContextMenu,
                            onEdit: onEdit,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Task task;
  final ProjectProvider project;
  final void Function(Task task, Offset localPosition, RenderBox renderBox) onContextMenu;
  final void Function(Task task) onEdit;

  const _KanbanCard({
    super.key,
    required this.task,
    required this.project,
    required this.onContextMenu,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final taskProject = task.projectId != null ? project.getById(task.projectId!) : null;

    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
          child: Text(task.title, style: const TextStyle(color: AppColors.text, fontSize: 14)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _cardContent(taskProject)),
      child: GestureDetector(
        onSecondaryTapDown: (details) {
          final box = context.findRenderObject() as RenderBox;
          onContextMenu(task, details.localPosition, box);
        },
        onTap: () => onEdit(task),
        child: _cardContent(taskProject),
      ),
    );
  }

  Widget _cardContent(dynamic project) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(color: task.priority.color, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: task.isCompleted ? AppColors.textSecondary : AppColors.text,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            if (project != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: project.color.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(project.name, style: const TextStyle(fontSize: 10, color: AppColors.text)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
