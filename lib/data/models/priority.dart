import 'package:flutter/material.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';

enum Priority {
  none,
  low,
  medium,
  high,
  urgent;

  String get label => switch (this) {
    Priority.none => 'None',
    Priority.low => 'Low',
    Priority.medium => 'Medium',
    Priority.high => 'High',
    Priority.urgent => 'Urgent',
  };

  Color get color => switch (this) {
    Priority.none => AppColors.priorityNone,
    Priority.low => AppColors.priorityLow,
    Priority.medium => AppColors.priorityMedium,
    Priority.high => AppColors.priorityHigh,
    Priority.urgent => AppColors.priorityUrgent,
  };

  IconData get icon => switch (this) {
    Priority.none => Icons.not_interested_outlined,
    Priority.low => Icons.signal_cellular_alt_1_bar_rounded,
    Priority.medium => Icons.signal_cellular_alt_2_bar_rounded,
    Priority.high => Icons.signal_cellular_alt_rounded,
    Priority.urgent => Icons.warning,
  };
}
