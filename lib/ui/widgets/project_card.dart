import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/project.dart';
import 'package:carpe_diem/data/models/label.dart';
import 'package:carpe_diem/providers/label_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: project.priority.color),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: project.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        project.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: AppColors.surfaceLight, shape: BoxShape.circle),
                      child: Icon(
                        project.priority.icon,
                        size: 16,
                        color: project.priority.color,
                        semanticLabel: project.priority.name,
                      ),
                    ),
                  ],
                ),
                if (project.description != null && project.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    project.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 12),
                Consumer<LabelProvider>(
                  builder: (context, labelProvider, _) {
                    final labels = project.labelIds.map((id) => labelProvider.getById(id)).whereType<Label>().toList();
                    if (labels.isEmpty) return const SizedBox.shrink();

                    return Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: labels.map((label) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
