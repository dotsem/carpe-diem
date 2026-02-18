import 'package:carpe_diem/ui/widgets/project_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/core/constants/app_constants.dart';
import 'package:carpe_diem/data/models/priority.dart';
import 'package:carpe_diem/providers/task_provider.dart';
import 'package:carpe_diem/providers/project_provider.dart';
import 'package:carpe_diem/ui/widgets/priority_picker.dart';
import 'package:carpe_diem/ui/dialogs/common/sized_dialog.dart';

class AddTaskDialog extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialProjectId;

  const AddTaskDialog({super.key, this.initialDate, this.initialProjectId});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedProjectId;
  Priority _priority = Priority.none;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedProjectId = widget.initialProjectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  DateTime get _maxDate => DateTime.now().add(const Duration(days: AppConstants.maxPlanningDaysAhead));

  @override
  Widget build(BuildContext context) {
    final projects = context.read<ProjectProvider>().projects;

    return SizedDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Task', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Task title'),
            style: const TextStyle(color: AppColors.text),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(hintText: 'Description (optional)'),
            style: const TextStyle(color: AppColors.text),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Text('Priority', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          PriorityPicker(selected: _priority, onChanged: (p) => setState(() => _priority = p)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DatePickerButton(
                  label: 'Schedule date',
                  date: _selectedDate,
                  maxDate: _maxDate,
                  onChanged: (d) => setState(() => _selectedDate = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProjectPicker(
                  projects: projects,
                  selectedProjectId: _selectedProjectId,
                  onChanged: (id) => setState(() => _selectedProjectId = id),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DatePickerButton(
            label: 'Deadline',
            date: _deadline,
            firstDate: DateTime.now(),
            onChanged: (d) => setState(() => _deadline = d),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              const SizedBox(width: 12),
              FilledButton(onPressed: _submit, child: const Text('Add Task')),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    context.read<TaskProvider>().addTask(
      title: title,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      scheduledDate: _selectedDate,
      projectId: _selectedProjectId,
      priority: _priority,
      deadline: _deadline,
    );
    Navigator.of(context).pop();
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateTime? firstDate;
  final DateTime? maxDate;
  final ValueChanged<DateTime?> onChanged;

  const _DatePickerButton({
    required this.label,
    required this.date,
    this.firstDate,
    this.maxDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2000),
          lastDate: maxDate ?? DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              date != null ? '${date!.day}/${date!.month}/${date!.year}' : label,
              style: TextStyle(color: date != null ? AppColors.text : AppColors.textSecondary),
            ),
            if (date != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
