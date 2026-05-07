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
