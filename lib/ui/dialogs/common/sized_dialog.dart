import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SizedDialog extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double maxWidth;

  const SizedDialog({super.key, required this.child, this.padding = const EdgeInsets.all(24), this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding!, child: child),
      ),
    );
  }
}
