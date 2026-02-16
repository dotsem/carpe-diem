import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/ui/dialogs/edit_task_dialog.dart';
import 'package:carpe_diem/ui/dialogs/pick_tasks_from_backlog_dialog.dart';
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
        const Divider(height: 1),
        Expanded(child: _taskList()),
      ],
    );
  }

  Widget _header(BuildContext context) {
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

  Widget _taskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final projectProvider = context.read<ProjectProvider>();
        final overdue = provider.overdueTasks;
        final tasks = provider.tasks;

        if (overdue.isEmpty && tasks.isEmpty) {
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
            if (overdue.isNotEmpty && _isToday) ...[
              Text(
                'Overdue',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...overdue.map(
                (task) => TaskCard(
                  task: task,
                  project: task.projectId != null ? projectProvider.getById(task.projectId!) : null,
                  isOverdue: true,
                  onToggle: () => provider.toggleComplete(task),
                  onTap: () {},
                  onContextMenu: (localPosition, renderBox) =>
                      _showContextMenu(context, task, localPosition, renderBox),
                  trailing: _taskTrailing(context, task),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (tasks.isNotEmpty) ...[
              Text('Tasks', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...tasks.map(
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

  void _showContextMenu(BuildContext context, Task task, Offset localPosition, RenderBox renderBox) {
    final provider = context.read<TaskProvider>();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset position = renderBox.localToGlobal(localPosition, ancestor: overlay);

    showMenu(
      context: context,
      position: RelativeRect.fromRect(Rect.fromLTWH(position.dx, position.dy, 0, 0), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          onTap: () => provider.scheduleTasksForTomorrow([task.id]),
          child: const ListTile(
            leading: Icon(Icons.next_plan_outlined),
            title: Text('Reschedule for Tomorrow'),
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
}
