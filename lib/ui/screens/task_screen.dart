import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/task_status.dart';
import 'package:carpe_diem/data/models/task_filter.dart';
import 'package:carpe_diem/ui/dialogs/add_task_dialog.dart';
import 'package:carpe_diem/ui/dialogs/edit_task_dialog.dart';
import 'package:carpe_diem/ui/dialogs/filter_dialog.dart';
import 'package:carpe_diem/ui/dialogs/import_from_md_dialog.dart';
import 'package:carpe_diem/ui/widgets/filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/providers/task_provider.dart';
import 'package:carpe_diem/providers/project_provider.dart';
import 'package:carpe_diem/ui/widgets/task_card.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  TaskFilter _filter = const TaskFilter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadUnscheduledTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        FilterBar(
          filter: _filter,
          onFilterTap: () => _showFilterDialog(context),
          onClearFilter: () => setState(() => _filter = const TaskFilter()),
        ),
        const Divider(height: 1),
        Expanded(child: _taskList()),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Backlog', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Tasks without a scheduled date', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          FilledButton.icon(onPressed: () => _showImportFromMD(context), label: const Text('Import from MD')),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showAddTask(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _taskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final projectProvider = context.read<ProjectProvider>();
        final allTasks = provider.unscheduledTasks.where((t) {
          final project = t.projectId != null ? projectProvider.getById(t.projectId!) : null;
          return _filter.applyToTask(t, project?.labelIds ?? []);
        }).toList();

        final activeTasks = allTasks.where((t) => !t.isCompleted).toList();
        final completedTasks = allTasks.where((t) => t.isCompleted).toList();

        if (activeTasks.isEmpty && completedTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inbox_rounded, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                const Text('No backlog tasks', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 8),
                TextButton(onPressed: () => _showAddTask(context), child: const Text('Add a task')),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
          children: [
            ...activeTasks.map(
              (task) => TaskCard(
                task: task,
                project: task.projectId != null ? projectProvider.getById(task.projectId!) : null,
                onToggle: () => provider.toggleComplete(task),
                onTap: () {},
                onContextMenu: (localPosition, renderBox) => _showContextMenu(context, task, localPosition, renderBox),
                trailing: _taskTrailing(context, task),
              ),
            ),
            if (completedTasks.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Completed',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              ...completedTasks.map(
                (task) => TaskCard(
                  task: task,
                  project: task.projectId != null ? projectProvider.getById(task.projectId!) : null,
                  onToggle: () => provider.toggleComplete(task),
                  onTap: () {},
                  onContextMenu: (localPosition, renderBox) =>
                      _showContextMenu(context, task, localPosition, renderBox),
                  trailing: _taskTrailing(context, task),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showContextMenu(BuildContext context, Task task, Offset localPosition, RenderBox renderBox) {
    final provider = context.read<TaskProvider>();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset position = renderBox.localToGlobal(localPosition, ancestor: overlay);

    final items = <PopupMenuEntry<void>>[];

    if (task.status.isTodo) {
      items.add(
        PopupMenuItem(
          onTap: () => provider.updateTaskStatus(task, TaskStatus.inProgress),
          child: const ListTile(leading: Icon(Icons.play_arrow), title: Text('Start (In Progress)'), dense: true),
        ),
      );
      items.add(
        PopupMenuItem(
          onTap: () => provider.updateTaskStatus(task, TaskStatus.done),
          child: const ListTile(leading: Icon(Icons.check_circle_outline), title: Text('Mark as Done'), dense: true),
        ),
      );
    }

    if (task.status.isInProgress) {
      items.add(
        PopupMenuItem(
          onTap: () => provider.updateTaskStatus(task, TaskStatus.todo),
          child: const ListTile(leading: Icon(Icons.undo), title: Text('Back to Todo'), dense: true),
        ),
      );
      items.add(
        PopupMenuItem(
          onTap: () => provider.updateTaskStatus(task, TaskStatus.done),
          child: const ListTile(leading: Icon(Icons.check_circle_outline), title: Text('Mark as Done'), dense: true),
        ),
      );
    }

    if (task.status.isDone) {
      items.add(
        PopupMenuItem(
          onTap: () => provider.updateTaskStatus(task, TaskStatus.todo),
          child: const ListTile(leading: Icon(Icons.undo), title: Text('Back to Todo'), dense: true),
        ),
      );
      items.add(
        PopupMenuItem(
          onTap: () => provider.updateTaskStatus(task, TaskStatus.inProgress),
          child: const ListTile(leading: Icon(Icons.play_arrow), title: Text('Back to In Progress'), dense: true),
        ),
      );
    }

    items.addAll([
      PopupMenuItem(
        onTap: () => provider.scheduleTasksForToday([task.id]),
        child: const ListTile(leading: Icon(Icons.today), title: Text('Schedule for Today'), dense: true),
      ),
      PopupMenuItem(
        onTap: () => provider.scheduleTasksForTomorrow([task.id]),
        child: const ListTile(
          leading: Icon(Icons.next_plan_outlined),
          title: Text('Schedule for Tomorrow'),
          dense: true,
        ),
      ),
      PopupMenuItem(
        onTap: () => _showEditTask(context, task),
        child: const ListTile(leading: Icon(Icons.edit), title: Text('Edit'), dense: true),
      ),
      PopupMenuItem(
        onTap: () => provider.deleteTask(task),
        child: const ListTile(
          leading: Icon(Icons.delete, color: AppColors.error),
          title: Text('Delete', style: TextStyle(color: AppColors.error)),
          dense: true,
        ),
      ),
    ]);

    showMenu(
      context: context,
      position: RelativeRect.fromRect(Rect.fromLTWH(position.dx, position.dy, 0, 0), Offset.zero & overlay.size),
      items: items,
    );
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

  void _showAddTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TaskProvider>(),
        child: ChangeNotifierProvider.value(value: context.read<ProjectProvider>(), child: const AddTaskDialog()),
      ),
    );
  }

  void _showEditTask(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TaskProvider>(),
        child: ChangeNotifierProvider.value(
          value: context.read<ProjectProvider>(),
          child: EditTaskDialog(task: task),
        ),
      ),
    );
  }

  void _showImportFromMD(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TaskProvider>(),
        child: ChangeNotifierProvider.value(value: context.read<ProjectProvider>(), child: const ImportFromMDDialog()),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) async {
    final result = await showDialog<TaskFilter>(
      context: context,
      builder: (_) => FilterDialog(initialFilter: _filter),
    );
    if (result != null) {
      setState(() => _filter = result);
    }
  }
}
