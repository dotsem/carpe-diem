import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/priority.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/providers/task_provider.dart';
import 'package:carpe_diem/ui/dialogs/delete_dialog.dart';
import 'package:carpe_diem/ui/widgets/priority_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTaskDialog extends StatefulWidget {
  final Task task;
  const EditTaskDialog({super.key, required this.task});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.task.title;
    _descController.text = widget.task.description ?? '';
    _priority = widget.task.priority;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Task', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Task name'),
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => DeleteDialog(
                        title: 'Delete Task',
                        message: 'Are you sure you want to delete this task?',
                        onConfirm: () {
                          Navigator.of(context).pop();
                          context.read<TaskProvider>().deleteTask(widget.task);
                        },
                      ),
                    ),
                    icon: const Icon(Icons.delete),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                    label: const Text("Delete"),
                  ),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: _submit, child: const Text('Save Changes')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) return;
    context.read<TaskProvider>().updateTask(
      widget.task.copyWith(
        title: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        priority: _priority,
      ),
    );
    Navigator.of(context).pop();
  }
}
