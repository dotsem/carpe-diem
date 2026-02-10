import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/priority.dart';
import 'package:carpe_diem/data/models/project.dart';
import 'package:carpe_diem/providers/project_provider.dart';
import 'package:carpe_diem/ui/dialogs/delete_dialog.dart';
import 'package:carpe_diem/ui/widgets/color_picker.dart';
import 'package:carpe_diem/ui/widgets/priority_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProjectDialog extends StatefulWidget {
  final Project project;
  const EditProjectDialog({super.key, required this.project});

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  late Color _selectedColor;
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.project.name;
    _descController.text = widget.project.description ?? '';
    _selectedColor = widget.project.color;
    _priority = widget.project.priority;
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
              Text('Edit Project', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Project name'),
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
              Text('Color', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              ProjectColorPicker(selected: _selectedColor, onChanged: (c) => setState(() => _selectedColor = c)),
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
                        title: 'Delete Project',
                        message: 'Are you sure you want to delete this project?',
                        onConfirm: () {
                          Navigator.of(context).pop();
                          context.read<ProjectProvider>().deleteProject(widget.project.id);
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
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final project = Project(
      id: widget.project.id,
      name: name,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      color: _selectedColor,
      priority: _priority,
      createdAt: widget.project.createdAt,
      updatedAt: DateTime.now(),
    );
    context.read<ProjectProvider>().updateProject(project);
    Navigator.of(context).pop();
  }
}
