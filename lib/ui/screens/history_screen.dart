import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/task_filter.dart';
import 'package:carpe_diem/providers/project_provider.dart';
import 'package:carpe_diem/providers/task_provider.dart';
import 'package:carpe_diem/ui/dialogs/filter_dialog.dart';
import 'package:carpe_diem/ui/dialogs/pick_date_range_dialog.dart';
import 'package:carpe_diem/ui/widgets/filter_bar.dart';
import 'package:carpe_diem/ui/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:carpe_diem/data/models/task.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );
  TaskFilter _filter = const TaskFilter();
  bool _isLoading = false;
  List<Task> _completedTasks = [];
  DateTime? _minDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final taskProvider = context.read<TaskProvider>();

    // Load first task date if not already loaded
    _minDate ??= await taskProvider.getFirstTaskDate();

    // Normalize dates to start of day and end of day
    final start = DateTime(_dateRange.start.year, _dateRange.start.month, _dateRange.start.day);
    final end = DateTime(_dateRange.end.year, _dateRange.end.month, _dateRange.end.day, 23, 59, 59);

    final tasks = await taskProvider.getCompletedTasks(start, end);

    if (mounted) {
      setState(() {
        _completedTasks = tasks;
        _isLoading = false;
      });
    }
  }

  void _selectDateRange() async {
    final now = DateTime.now();
    final initialDateRange = _dateRange;
    final firstDate = _minDate ?? now.subtract(const Duration(days: 365 * 10)); // Fallback if minDate is null

    final picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) =>
          PickDateRangeDialog(initialDateRange: initialDateRange, firstDate: firstDate, lastDate: now),
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _loadData();
    }
  }

  void _showFilterDialog() async {
    final result = await showDialog<TaskFilter>(
      context: context,
      builder: (context) => FilterDialog(initialFilter: _filter),
    );

    if (result != null) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply filters to loaded tasks
    final projectProvider = context.watch<ProjectProvider>();
    final filteredTasks = _completedTasks.where((task) {
      final project = task.projectId != null ? projectProvider.getById(task.projectId!) : null;
      final inheritedLabelIds = project?.labelIds ?? [];
      return _filter.applyToTask(task, inheritedLabelIds);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          Row(
            children: [
              Text(
                'History',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: AppColors.text, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildDateRangeButton(),
            ],
          ),
          const SizedBox(height: 8),
          FilterBar(
            filter: _filter,
            onFilterTap: _showFilterDialog,
            onClearFilter: () => setState(() => _filter = const TaskFilter()),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTasks.isEmpty
                ? _buildEmptyState()
                : _buildTaskList(filteredTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeButton() {
    final dateFormat = DateFormat('MMM d, yyyy');
    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(
              '${dateFormat.format(_dateRange.start)} - ${dateFormat.format(_dateRange.end)}',
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    final projectProvider = context.read<ProjectProvider>();

    // Group tasks by completion date
    final groupedTasks = <String, List<Task>>{};
    for (final task in tasks) {
      if (task.completedAt == null) continue;
      final dateKey = DateFormat('yyyy-MM-dd').format(task.completedAt!);
      groupedTasks.putIfAbsent(dateKey, () => []).add(task);
    }

    final sortedKeys = groupedTasks.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final dayTasks = groupedTasks[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Text(
                _formatDateHeader(date),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
            ),
            ...dayTasks.map((task) {
              final project = task.projectId != null ? projectProvider.getById(task.projectId!) : null;
              return TaskCard(
                task: task,
                project: project,
                onToggle: (_) {}, // Read-only for history
                onTap: () {
                  // TODO: Show task details if needed, but for now history is primary
                },
                leading: const SizedBox.shrink(),
                showStrikeThroughOnCompleted: false,
              );
            }),
          ],
        );
      },
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) return 'TODAY';
    if (date.isAtSameMomentAs(yesterday)) return 'YESTERDAY';

    return DateFormat('EEEE, MMM d').format(date).toUpperCase();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textSecondary.withAlpha(50)),
          const SizedBox(height: 16),
          Text('No completed tasks found', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different date range or clearing filters',
            style: TextStyle(color: AppColors.textSecondary.withAlpha(150), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
