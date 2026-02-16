import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/providers/label_provider.dart';
import 'package:carpe_diem/ui/widgets/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddLabelDialog extends StatefulWidget {
  const AddLabelDialog({super.key});

  @override
  State<AddLabelDialog> createState() => _AddLabelDialogState();
}

class _AddLabelDialogState extends State<AddLabelDialog> {
  final nameController = TextEditingController();
  Color selectedColor = AppColors.accent;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Label'),
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
        FilledButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isNotEmpty) {
              context.read<LabelProvider>().addLabel(name: name, color: selectedColor);
              Navigator.pop(context);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
