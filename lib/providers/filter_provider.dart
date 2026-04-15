import 'package:carpe_diem/data/models/task_filter.dart';
import 'package:flutter/foundation.dart';

class FilterProvider extends ChangeNotifier {
  TaskFilter _filter = const TaskFilter();

  TaskFilter get filter => _filter;

  void setFilter(TaskFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void clearFilter() {
    if (_filter.isEmpty) return;
    _filter = const TaskFilter();
    notifyListeners();
  }
}
