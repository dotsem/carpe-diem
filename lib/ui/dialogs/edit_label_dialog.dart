import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/label.dart';
import 'package:carpe_diem/providers/label_provider.dart';
import 'package:carpe_diem/ui/widgets/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditLabelDialog extends StatefulWidget {
  final Label label;
  const EditLabelDialog({super.key, required this.label});

  @override
  State<EditLabelDialog> createState() => _EditLabelDialogState();
}

class _EditLabelDialogState extends State<EditLabelDialog> {
  late TextEditingController nameController;
  Color selectedColor = AppColors.accent;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.label.name);
    selectedColor = widget.label.color;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Label'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Label name'),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          ProjectColorPicker(selected: selectedColor, onChanged: (c) => setState(() => selectedColor = c)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Update')),
      ],
    );
  }

  void _submit() {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    context.read<LabelProvider>().updateLabel(widget.label.copyWith(name: name, color: selectedColor));
    Navigator.of(context).pop();
  }
}
