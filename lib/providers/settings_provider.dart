import 'package:carpe_diem/core/constants/app_constants.dart';
import 'package:carpe_diem/data/models/task_layout.dart';
import 'package:carpe_diem/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo = SettingsRepository();
  Map<String, String> _settings = {};

  Future<void> loadSettings() async {
    _settings = await _repo.getAll();
    notifyListeners();
  }

  // Generic helper to get a setting with a default
  String _get(String key, String defaultValue) => _settings[key] ?? defaultValue;

  // Generic helper to set a setting
  Future<void> _set(String key, String value) async {
    _settings[key] = value;
    await _repo.set(key, value);
    notifyListeners();
  }

  // Task Layout
  TaskLayout getTaskLayout() {
    final layoutStr = _get('task_layout', TaskLayout.list.name);
    try {
      return TaskLayout.fromString(layoutStr);
    } catch (_) {
      return TaskLayout.list;
    }
  }

  Future<void> setTaskLayout(TaskLayout layout) => _set('task_layout', layout.name);

  // Max Planning Days
  int get maxPlanningDays => int.tryParse(_get(AppConstants.keyMaxPlanningDays, AppConstants.maxPlanningDaysAhead.toString())) ?? AppConstants.maxPlanningDaysAhead;
  Future<void> setMaxPlanningDays(int days) => _set(AppConstants.keyMaxPlanningDays, days.toString());

  // First Day of Week
  int get firstDayOfWeek => int.tryParse(_get(AppConstants.keyFirstDayOfWeek, AppConstants.firstDayOfWeek.toString())) ?? AppConstants.firstDayOfWeek;
  Future<void> setFirstDayOfWeek(int day) => _set(AppConstants.keyFirstDayOfWeek, day.toString());

  // Task Completion Delay
  int get taskCompletionDelay => int.tryParse(_get(AppConstants.keyTaskDelay, AppConstants.taskCompletionDelaySeconds.toString())) ?? AppConstants.taskCompletionDelaySeconds;
  Future<void> setTaskCompletionDelay(int seconds) => _set(AppConstants.keyTaskDelay, seconds.toString());

  // Inherit Parent Deadline
  bool get inheritParentDeadline => _get(AppConstants.keyInheritParentDeadline, AppConstants.inheritParentDeadline.toString()) == 'true';
  Future<void> setInheritParentDeadline(bool value) => _set(AppConstants.keyInheritParentDeadline, value.toString());

  // Prioritize Deadlines
  bool get prioritizeDeadlines => _get(AppConstants.keyPrioritizeDeadlines, AppConstants.prioritizeDeadlines.toString()) == 'true';
  Future<void> setPrioritizeDeadlines(bool value) => _set(AppConstants.keyPrioritizeDeadlines, value.toString());

  // Inherit Project Deadline
  bool get inheritProjectDeadline => _get(AppConstants.keyInheritProjectDeadline, AppConstants.inheritProjectDeadline.toString()) == 'true';
  Future<void> setInheritProjectDeadline(bool value) => _set(AppConstants.keyInheritProjectDeadline, value.toString());

  // Theme Mode
  ThemeMode get themeMode {
    final modeStr = _get(AppConstants.keyThemeMode, ThemeMode.system.name);
    return ThemeMode.values.firstWhere((e) => e.name == modeStr, orElse: () => ThemeMode.system);
  }

  Future<void> setThemeMode(ThemeMode mode) => _set(AppConstants.keyThemeMode, mode.name);

  // Use System Color
  bool get useSystemColor => _get(AppConstants.keyUseSystemColor, 'true') == 'true';
  Future<void> setUseSystemColor(bool value) => _set(AppConstants.keyUseSystemColor, value.toString());
}
