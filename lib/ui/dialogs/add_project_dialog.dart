import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/priority.dart';
import 'package:carpe_diem/providers/project_provider.dart';
import 'package:carpe_diem/ui/widgets/priority_picker.dart';
import 'package:carpe_diem/ui/widgets/color_picker.dart';
import 'package:carpe_diem/ui/widgets/label_picker.dart';
import 'package:carpe_diem/ui/dialogs/common/sized_dialog.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  Color _selectedColor = AppColors.accent;
  Priority _priority = Priority.none;
  List<String> _selectedLabelIds = [];
  DateTime? _deadline;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Project', style: Theme.of(context).textTheme.titleLarge),
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
          const SizedBox(height: 16),
          Text('Labels', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          LabelPicker(
            selectedLabelIds: _selectedLabelIds,
            onSelected: (ids) => setState(() => _selectedLabelIds = ids),
          ),
          const SizedBox(height: 16),
          _DatePickerButton(label: 'Deadline', date: _deadline, onChanged: (d) => setState(() => _deadline = d)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              const SizedBox(width: 12),
              FilledButton(onPressed: _submit, child: const Text('Create Project')),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    context.read<ProjectProvider>().addProject(
      name: name,
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      color: _selectedColor,
      priority: _priority,
      labelIds: _selectedLabelIds,
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
          initialDate: (date != null && date!.isAfter(firstDate ?? DateTime(2000)))
              ? date!
              : (firstDate ?? DateTime.now()),
          firstDate: firstDate ?? DateTime.now(),
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
