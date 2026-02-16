import 'package:carpe_diem/ui/dialogs/add_label_dialog.dart';
import 'package:carpe_diem/ui/widgets/context_menu/label_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/providers/label_provider.dart';

class LabelPicker extends StatelessWidget {
  final List<String> selectedLabelIds;
  final ValueChanged<List<String>> onSelected;
  final bool allowAdd;

  const LabelPicker({super.key, required this.selectedLabelIds, required this.onSelected, this.allowAdd = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<LabelProvider>(
      builder: (context, provider, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...provider.labels.map((label) {
              final isSelected = selectedLabelIds.contains(label.id);
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
                  child: FilterChip(
                    label: Text(label.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newIds = List<String>.from(selectedLabelIds);
                      if (selected) {
                        newIds.add(label.id);
                      } else {
                        newIds.remove(label.id);
                      }
                      onSelected(newIds);
                    },
                    avatar: CircleAvatar(backgroundColor: label.color, radius: 6),
                    backgroundColor: AppColors.surfaceLight,
                    selectedColor: label.color.withAlpha(200),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
                  ),
                ),
              );
            }),
            if (allowAdd)
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
