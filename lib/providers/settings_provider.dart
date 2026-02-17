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

  Future<void> setTaskLayout(TaskLayout layout) async {
    _settings['task_layout'] = layout.name;
    await _repo.set('task_layout', layout.name);
    notifyListeners();
  }

  TaskLayout getTaskLayout() {
    final layoutStr = _settings['task_layout'] ?? TaskLayout.list.name;
    try {
      return TaskLayout.fromString(layoutStr);
    } catch (_) {
      return TaskLayout.list;
    }
  }
}
