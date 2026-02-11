import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/providers/task_provider.dart';
import 'package:carpe_diem/ui/widgets/task_card.dart';
import 'package:carpe_diem/ui/dialogs/common/sized_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PickTaskFromBacklogDialog extends StatefulWidget {
  const PickTaskFromBacklogDialog({super.key});

  @override
  State<PickTaskFromBacklogDialog> createState() => _PickTaskFromBacklogDialogState();
}

class _PickTaskFromBacklogDialogState extends State<PickTaskFromBacklogDialog> {
  List<Task> _backlog = [];
  final Set<String> _selectedTaskIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBacklog();
  }

  Future<void> _loadBacklog() async {
    final backlog = await context.read<TaskProvider>().getBacklog();
    if (mounted) {
      setState(() {
        _backlog = backlog;
        _isLoading = false;
      });
    }
  }

  void _toggleSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  Future<void> _addSelectedTasks() async {
    if (_selectedTaskIds.isEmpty) return;

    await context.read<TaskProvider>().scheduleTasksForToday(_selectedTaskIds.toList());
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedDialog(
      maxWidth: 800,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pick Tasks from Backlog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (!_isLoading && _backlog.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No tasks in backlog', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          if (!_isLoading && _backlog.isNotEmpty)
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _backlog
                      .map(
                        (task) => TaskCard(
                          task: task,
                          selectionMode: true,
                          isSelected: _selectedTaskIds.contains(task.id),
                          onTap: () => _toggleSelection(task.id),
                          onToggle: () => _toggleSelection(task.id),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _selectedTaskIds.isNotEmpty ? _addSelectedTasks : null,
                child: Text(_selectedTaskIds.isEmpty ? 'Add Tasks' : 'Add ${_selectedTaskIds.length} Tasks'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
