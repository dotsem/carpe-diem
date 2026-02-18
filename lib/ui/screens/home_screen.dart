import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/task_layout.dart';
import 'package:carpe_diem/data/models/task_filter.dart';
import 'package:carpe_diem/ui/dialogs/edit_task_dialog.dart';
import 'package:carpe_diem/ui/dialogs/filter_dialog.dart';
import 'package:carpe_diem/ui/widgets/context_menu/task_card_context_menu.dart';
import 'package:carpe_diem/ui/widgets/filter_bar.dart';
import 'package:carpe_diem/ui/dialogs/pick_tasks_from_backlog_dialog.dart';
import 'package:carpe_diem/ui/widgets/kanban_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/core/constants/app_constants.dart';
import 'package:carpe_diem/providers/task_provider.dart';
import 'package:carpe_diem/providers/project_provider.dart';
import 'package:carpe_diem/ui/widgets/task_card.dart';
import 'package:carpe_diem/ui/dialogs/add_task_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  TaskFilter _filter = const TaskFilter();
  final _dateFormat = DateFormat('EEEE, MMMM d');

  @override
  void initState() {
    super.initState();
    _selectedDate = _today;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasksForDate(_selectedDate);
    });
  }

  DateTime get _today => DateTime.now();
  DateTime get _normalizedSelected => DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

  bool get _isToday {
    final now = _today;
    return _normalizedSelected == DateTime(now.year, now.month, now.day);
  }

  List<DateTime> get _days {
    final today = DateTime(_today.year, _today.month, _today.day);
    return List.generate(AppConstants.maxPlanningDaysAhead + 1, (i) => today.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        _daySelector(),
        FilterBar(
          filter: _filter,
          onFilterTap: () => _showFilterDialog(context),
          onClearFilter: () => setState(() => _filter = const TaskFilter()),
        ),
        const Divider(height: 1),
        Expanded(child: _body()),
      ],
    );
  }

  Widget _header(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isToday ? 'Today' : _dateFormat.format(_selectedDate),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _isToday
                    ? _dateFormat.format(_selectedDate)
                    : '${_normalizedSelected.difference(DateTime(_today.year, _today.month, _today.day)).inDays} days from now',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => provider.toggleLayoutMode(),
            icon: Icon(provider.layoutMode == TaskLayout.list ? Icons.view_kanban : Icons.view_list),
            tooltip: provider.layoutMode == TaskLayout.list ? 'Kanban view' : 'List view',
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _showPickTasksFromBacklog(context),
            icon: const Icon(Icons.inbox_rounded),
            label: const Text('Pick Tasks from Backlog'),
          ),
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

  Widget _daySelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 12),
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _days.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final day = _days[index];
            final isSelected = _normalizedSelected == day;
            final dayOfWeek = DateFormat('E').format(day);
            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = day);
                context.read<TaskProvider>().loadTasksForDate(day);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayOfWeek,
                      style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _body() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final projectProvider = context.read<ProjectProvider>();

        final overdue = provider.overdueTasks.where((t) {
          final project = t.projectId != null ? projectProvider.getById(t.projectId!) : null;
          return _filter.applyToTask(t, project?.labelIds ?? []);
        }).toList();

        final allTasks = provider.tasks.where((t) {
          final project = t.projectId != null ? projectProvider.getById(t.projectId!) : null;
          return _filter.applyToTask(t, project?.labelIds ?? []);
        }).toList();

        if (provider.layoutMode == TaskLayout.kanban) {
          return KanbanBoard(
            tasks: [...overdue, ...allTasks],
            projectProvider: projectProvider,
            onStatusChange: (task, status) => provider.updateTaskStatus(task, status),
            onContextMenu: (task, pos, box) => showTaskCardContextMenu(context, task, pos, box),
            onEdit: (task) => _showEditTask(context, task),
          );
        }

        return _listLayout(provider, projectProvider, overdue, allTasks);
      },
    );
  }

  Widget _listLayout(TaskProvider provider, ProjectProvider projectProvider, List<Task> overdue, List<Task> allTasks) {
    final inProgressTasks = allTasks.where((t) => t.status.isInProgress).toList();
    final todoTasks = allTasks.where((t) => t.status.isTodo).toList();
    final completedTasks = allTasks.where((t) => t.isCompleted).toList();

    if (overdue.isEmpty && inProgressTasks.isEmpty && todoTasks.isEmpty && completedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              _isToday ? 'No tasks for today' : 'No tasks scheduled',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: () => _showAddTask(context), child: const Text('Add your first task')),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      children: [
        if (inProgressTasks.isNotEmpty) ...[
          Text(
            'In Progress',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...inProgressTasks.map((task) => _buildTaskCard(task, projectProvider, provider)),
          const SizedBox(height: 20),
        ],
        if (overdue.isNotEmpty && _isToday) ...[
          Text(
            'Overdue',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...overdue.map((task) => _buildTaskCard(task, projectProvider, provider, isOverdue: true)),
          const SizedBox(height: 20),
        ],
        if (todoTasks.isNotEmpty) ...[
          if (inProgressTasks.isNotEmpty || (overdue.isNotEmpty && _isToday))
            Text('Todo', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          if (inProgressTasks.isNotEmpty || (overdue.isNotEmpty && _isToday)) const SizedBox(height: 8),
          ...todoTasks.map((task) => _buildTaskCard(task, projectProvider, provider)),
        ],
        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Done',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ...completedTasks.map((task) => _buildTaskCard(task, projectProvider, provider)),
        ],
      ],
    );
  }

  TaskCard _buildTaskCard(Task task, ProjectProvider projectProvider, TaskProvider provider, {bool isOverdue = false}) {
    return TaskCard(
      key: ValueKey(task.id),
      task: task,
      project: task.projectId != null ? projectProvider.getById(task.projectId!) : null,
      isOverdue: isOverdue,
      onToggle: () => provider.toggleComplete(task),
      onTap: () {},
      onContextMenu: (localPosition, renderBox) => showTaskCardContextMenu(context, task, localPosition, renderBox),
      trailing: _taskTrailing(context, task),
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
        child: ChangeNotifierProvider.value(
          value: context.read<ProjectProvider>(),
          child: AddTaskDialog(initialDate: _selectedDate),
        ),
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

  void _showPickTasksFromBacklog(BuildContext context) {
    showDialog(context: context, builder: (_) => PickTaskFromBacklogDialog());
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
