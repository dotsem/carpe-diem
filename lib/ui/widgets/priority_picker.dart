import 'package:flutter/material.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/priority.dart';

class PriorityPicker extends StatelessWidget {
  final Priority selected;
  final ValueChanged<Priority> onChanged;

  const PriorityPicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((p) {
        final isSelected = p == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(p.label),
            selected: isSelected,
            onSelected: (_) => onChanged(p),
            avatar: Icon(p.icon, size: 16, color: isSelected ? Colors.white : p.color),
            selectedColor: p.color,
            backgroundColor: AppColors.surfaceLight,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 13),
          ),
        );
      }).toList(),
    );
  }
}
