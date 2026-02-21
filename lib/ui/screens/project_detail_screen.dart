import 'package:carpe_diem/data/models/label.dart';
import 'package:carpe_diem/providers/label_provider.dart';
import 'package:carpe_diem/ui/widgets/chip/chip.dart';
import 'package:carpe_diem/ui/widgets/chip/label_chip.dart';
import 'package:carpe_diem/ui/widgets/priority_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/project.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/providers/project_provider.dart';
import 'package:carpe_diem/providers/task_provider.dart';
import 'package:carpe_diem/ui/widgets/task_list_view.dart';
import 'package:carpe_diem/ui/widgets/context_menu/task_card_context_menu.dart';
import 'package:carpe_diem/ui/dialogs/edit_task_dialog.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _isLoading = true;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didUpdateWidget(covariant ProjectDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      _loadTasks();
    }
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final taskProvider = context.read<TaskProvider>();
    final tasks = await taskProvider.getTasksForProject(widget.projectId);
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        final project = projectProvider.getById(widget.projectId);

        if (project == null) {
          return const Center(
            child: Text("Project not found", style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(project),
              const Divider(color: AppColors.surfaceLight, height: 1),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TaskListView(
                        tasks: _tasks,
                        padding: const EdgeInsets.all(24),
                        onContextMenu: (ctx, task, pos, box) => showTaskCardContextMenu(ctx, task, pos, box),
                        trailingBuilder: (ctx, task) => _taskTrailing(ctx, task),
                        emptyPlaceholder: const Center(
                          child: Text("No tasks in this project", style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Project project) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, bottom: 0, child: PriorityIndicator(priority: project.priority)),
          Padding(
            padding: const EdgeInsets.only(left: 22), // width of indicator (6) + spacing (16)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: project.color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          project.name,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text),
                        ),
                      ),
                      // Could add edit buttons here in the future
                    ],
                  ),
                ),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    if (project.deadline != null) DeadlineChip(deadline: project.deadline!),
                    ..._getLabels(context, project),
                  ],
                ),
                if (project.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  // TODO: add expand button
                  Text(
                    project.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getLabels(BuildContext context, Project project) {
    final labelProvider = context.watch<LabelProvider>();
    final labels = project.labelIds.map((id) => labelProvider.getById(id)).whereType<Label>().toList();

    return labels.map((label) => LabelChip(label: label, verticalPadding: 1)).toList();
  }

  Widget _taskTrailing(BuildContext context, Task task) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 18),
          color: AppColors.textSecondary,
          onPressed: () => _showEditTask(context, task),
        ),
      ],
    );
  }

  void _showEditTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: context.read<TaskProvider>()),
          ChangeNotifierProvider.value(value: context.read<ProjectProvider>()),
        ],
        child: EditTaskDialog(task: task),
      ),
    );
  }
}
