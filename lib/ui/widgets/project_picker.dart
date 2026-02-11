import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/data/models/project.dart';
import 'package:flutter/material.dart';

class ProjectPicker extends StatefulWidget {
  final List<Project> projects;
  final Function(String?) onChanged;
  final String? selectedProjectId;
  const ProjectPicker({super.key, this.selectedProjectId, required this.onChanged, required this.projects});

  @override
  State<ProjectPicker> createState() => _ProjectPickerState();
}

class _ProjectPickerState extends State<ProjectPicker> {
  @override
  Widget build(BuildContext context) {
    return (widget.projects.isNotEmpty)
        ? DropdownButtonFormField<String?>(
            initialValue: widget.selectedProjectId,
            decoration: _inputDecoration(),
            dropdownColor: AppColors.surfaceLight,
            items: [
              const DropdownMenuItem(value: null, child: Text('No project')),
              ...widget.projects.map(
                (p) => DropdownMenuItem(
                  value: p.id,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(p.name),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: (v) => widget.onChanged(v),
          )
        : Expanded(
            child: DropdownButtonFormField<String?>(
              items: const [],
              onChanged: null,
              decoration: _inputDecoration().copyWith(hintText: 'No projects yet'),
            ),
          );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      hintText: 'Project',
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
