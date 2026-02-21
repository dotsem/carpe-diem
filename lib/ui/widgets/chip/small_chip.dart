import 'package:flutter/material.dart';

class SmallChip extends StatelessWidget {
  final Widget child;
  final Color color;
  const SmallChip({super.key, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: child,
    );
  }
}
