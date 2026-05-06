import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TaskHierarchyIndicator extends StatelessWidget {
  final int depth;
  final Widget child;

  const TaskHierarchyIndicator({super.key, required this.depth, required this.child});

  @override
  Widget build(BuildContext context) {
    if (depth == 0) return child;

    Widget current = child;
    for (int i = 0; i < depth; i++) {
      current = Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Theme.of(context).colorScheme.surfaceVariant, width: 2)),
        ),
        padding: const EdgeInsets.only(left: 8),
        child: current,
      );
    }

    return current;
  }
}
