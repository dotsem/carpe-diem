import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/ui/dialogs/common/sized_dialog.dart';
import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final Function() onConfirm;
  const DeleteDialog({super.key, required this.title, required this.message, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SizedDialog(
      title: title,
      submitText: 'Delete',
      submitStyle: FilledButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.text),
      onSubmit: () {
        Navigator.of(context).pop();
        onConfirm();
      },
      child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
