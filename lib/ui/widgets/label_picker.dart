import 'package:carpe_diem/ui/dialogs/add_label_dialog.dart';
import 'package:carpe_diem/ui/widgets/context_menu/label_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/providers/label_provider.dart';

class LabelPicker extends StatelessWidget {
  final String? selectedLabelId;
  final ValueChanged<String?> onSelected;

  const LabelPicker({super.key, this.selectedLabelId, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Consumer<LabelProvider>(
      builder: (context, provider, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('None'),
              selected: selectedLabelId == null,
              onSelected: (selected) {
                if (selected) onSelected(null);
              },
              backgroundColor: AppColors.surfaceLight,
              selectedColor: AppColors.accent,
            ),
            ...provider.labels.map((label) {
              final isSelected = label.id == selectedLabelId;
              return Builder(
                builder: (context) => GestureDetector(
                  onSecondaryTapDown: (details) {
                    showLabelContextMenu(
                      context,
                      label,
                      details.localPosition,
                      context.findRenderObject() as RenderBox,
                    );
                  },
                  child: ChoiceChip(
                    label: Text(label.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) onSelected(label.id);
                    },
                    avatar: CircleAvatar(backgroundColor: label.color, radius: 6),
                    backgroundColor: AppColors.surfaceLight,
                    selectedColor: label.color.withAlpha(200),
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
                  ),
                ),
              );
            }),
            ActionChip(
              label: const Text('New Label'),
              avatar: const Icon(Icons.add, size: 16),
              onPressed: () => _showAddLabel(context),
              backgroundColor: AppColors.surfaceLight,
            ),
          ],
        );
      },
    );
  }

  void _showAddLabel(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddLabelDialog());
  }
}
