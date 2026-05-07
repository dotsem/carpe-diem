import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:carpe_diem/core/utils/color_utils.dart';
import 'package:carpe_diem/providers/settings_provider.dart';
import 'package:carpe_diem/ui/widgets/label_picker.dart';
import 'package:carpe_diem/ui/widgets/screen_header.dart';
import 'package:carpe_diem/ui/widgets/settings/settings_components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Column(
          children: [
            ScreenHeader(title: 'Settings', subtitle: 'Manage your application preferences'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  SettingsSection(
                    title: 'Appearance',
                    children: [
                      SettingsDropdownTile<ThemeMode>(
                        icon: Icons.palette_outlined,
                        title: 'Theme Mode',
                        subtitle: 'Choose your preferred theme',
                        value: settings.themeMode,
                        items: [
                          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                        ],
                        onChanged: (value) {
                          if (value != null) settings.setThemeMode(value);
                        },
                      ),
                      SettingsSwitchTile(
                        icon: Icons.color_lens_outlined,
                        title: 'Dynamic Colors',
                        subtitle: 'Use system color palette (if supported)',
                        value: settings.useSystemColor,
                        onChanged: (value) => settings.setUseSystemColor(value),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task Card Gradient Width',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Drag on the card below to adjust project color intensity',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            _InteractiveTaskCard(
                              initialWidth: settings.taskGradientWidth,
                              onChanged: (val) => settings.setTaskGradientWidth(val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Labels',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: LabelPicker(selectedLabelIds: const [], onSelected: (_) {}, isManageMode: true),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Planning',
                    children: [
                      SettingsSliderTile(
                        icon: Icons.calendar_month_outlined,
                        title: 'Planning Horizon',
                        subtitle: 'Days ahead to show in the date selector',
                        value: settings.maxPlanningDays.toDouble(),
                        min: 3,
                        max: 14,
                        divisions: 11,
                        onChanged: (value) => settings.setMaxPlanningDays(value.round()),
                      ),
                      SettingsDropdownTile<int>(
                        icon: Icons.first_page_outlined,
                        title: 'First Day of Week',
                        subtitle: 'Start your week on Monday or Sunday',
                        value: settings.firstDayOfWeek,
                        items: [
                          DropdownMenuItem(value: DateTime.monday, child: Text('Monday')),
                          DropdownMenuItem(value: DateTime.sunday, child: Text('Sunday')),
                        ],
                        onChanged: (value) {
                          if (value != null) settings.setFirstDayOfWeek(value);
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Tasks',
                    children: [
                      SettingsSliderTile(
                        icon: Icons.timer_outlined,
                        title: 'Completion Delay',
                        subtitle: 'Seconds to wait before marking task as complete',
                        value: settings.taskCompletionDelay.toDouble(),
                        min: 0,
                        max: 10,
                        divisions: 10,
                        labelBuilder: (v) => '${v.round()}s',
                        onChanged: (value) => settings.setTaskCompletionDelay(value.round()),
                      ),
                      SettingsSwitchTile(
                        icon: Icons.subdirectory_arrow_right_outlined,
                        title: 'Inherit Parent Deadline',
                        subtitle: 'New subtasks inherit parent deadline',
                        value: settings.inheritParentDeadline,
                        onChanged: (value) => settings.setInheritParentDeadline(value),
                      ),
                      SettingsSwitchTile(
                        icon: Icons.folder_shared_outlined,
                        title: 'Inherit Project Deadline',
                        subtitle: 'New tasks inherit project deadline',
                        value: settings.inheritProjectDeadline,
                        onChanged: (value) => settings.setInheritProjectDeadline(value),
                      ),
                      SettingsSwitchTile(
                        icon: Icons.priority_high_outlined,
                        title: 'Prioritize Deadlines',
                        subtitle: 'Sort tasks by deadline first',
                        value: settings.prioritizeDeadlines,
                        onChanged: (value) => settings.setPrioritizeDeadlines(value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InteractiveTaskCard extends StatefulWidget {
  final double initialWidth;
  final ValueChanged<double> onChanged;

  const _InteractiveTaskCard({required this.initialWidth, required this.onChanged});

  @override
  State<_InteractiveTaskCard> createState() => _InteractiveTaskCardState();
}

class _InteractiveTaskCardState extends State<_InteractiveTaskCard> {
  late double _currentWidth;

  @override
  void initState() {
    super.initState();
    _currentWidth = widget.initialWidth;
  }

  @override
  void didUpdateWidget(_InteractiveTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialWidth != widget.initialWidth) {
      _currentWidth = widget.initialWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectColor = Colors.deepPurple.themeDependentColor(context);

    return GestureDetector(
      onPanUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localX = details.localPosition.dx;
        setState(() {
          _currentWidth = (1.0 - (localX / box.size.width)).clamp(0.0, 1.0);
        });
      },
      onPanEnd: (_) {
        widget.onChanged(_currentWidth);
      },
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface,
                projectColor.withValues(alpha: 0),
                projectColor.withValues(alpha: 0.4),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                0.0,
                (1.0 - _currentWidth).clamp(0.0, 1.0),
                (1.0 - _currentWidth).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Task Card',
                        style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      Text(
                        'Drag me horizontally to adjust width',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.drag_handle, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
