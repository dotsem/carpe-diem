import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProjectBreakdownItem extends StatelessWidget {
  final String projectName;
  final int taskCount;
  final Color projectColor;
  final double widthFactor;

  const ProjectBreakdownItem({
    super.key,
    required this.projectName,
    required this.taskCount,
    required this.projectColor,
    required this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                projectName,
                style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500),
              ),
              Text(
                '$taskCount tasks',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4)),
              ),
              FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(color: projectColor, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
