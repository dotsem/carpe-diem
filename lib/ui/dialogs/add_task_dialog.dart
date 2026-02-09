import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/core/constants/app_constants.dart';
import 'package:carpe_diem/data/models/priority.dart';
import 'package:carpe_diem/providers/task_provider.dart';
import 'package:carpe_diem/providers/project_provider.dart';
import 'package:carpe_diem/ui/widgets/priority_picker.dart';

class AddTaskDialog extends StatefulWidget {
  final DateTime initialDate;
  final String? initialProjectId;

  const AddTaskDialog({super.key, required this.initialDate, this.initialProjectId});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  late DateTime _selectedDate;
  String? _selectedProjectId;
  Priority _priority = Priority.none;

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

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                    child: _DatePickerButton(date: _selectedDate, maxDate: _maxDate, onChanged: (d) => setState(() => _selectedDate = d)),
                  ),
                  const SizedBox(width: 12),
                  if (projects.isNotEmpty)
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _selectedProjectId,
                        decoration: const InputDecoration(hintText: 'Project', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                        dropdownColor: AppColors.surfaceLight,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('No project')),
                          ...projects.map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(p.name),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => _selectedProjectId = v),
                      ),
                    ),
                ],
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
        ),
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    context.read<TaskProvider>().addTask(title: title, description: _descController.text.trim().isEmpty ? null : _descController.text.trim(), scheduledDate: _selectedDate, projectId: _selectedProjectId, priority: _priority);
    Navigator.of(context).pop();
  }
}

class _DatePickerButton extends StatelessWidget {
  final DateTime date;
  final DateTime maxDate;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerButton({required this.date, required this.maxDate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now(), lastDate: maxDate);
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
            Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}
