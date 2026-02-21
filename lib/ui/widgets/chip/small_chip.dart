import 'package:flutter/material.dart';

class SmallChip extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  const SmallChip({super.key, required this.child, required this.color, this.borderRadius = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(borderRadius)),
      child: child,
    );
  }
}
