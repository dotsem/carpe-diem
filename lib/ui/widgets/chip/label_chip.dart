import 'package:flutter/material.dart';
import 'package:carpe_diem/data/models/label.dart';

class LabelChip extends StatelessWidget {
  final Label label;
  final double verticalPadding;

  const LabelChip({super.key, required this.label, this.verticalPadding = 2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: label.color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: label.color.withAlpha(75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: label.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label.name,
            style: TextStyle(color: label.color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
