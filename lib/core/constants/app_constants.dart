class AppConstants {
  static const String appName = 'Carpe Diem';
  static const int maxPlanningDaysAhead = 7;
  static const String dbName = 'carpe_diem.db';
  static const int dbVersion = 11;
  static const int firstDayOfWeek = DateTime.monday;
  static const int taskCompletionDelaySeconds = 5;
  static const bool inheritParentDeadline = true;
  static const bool prioritizeDeadlines = true;
  static const bool inheritProjectDeadline = false;

  // Setting keys
  static const String keyMaxPlanningDays = 'max_planning_days';
  static const String keyFirstDayOfWeek = 'first_day_of_week';
  static const String keyTaskDelay = 'task_delay';
  static const String keyInheritParentDeadline = 'inherit_parent_deadline';
  static const String keyPrioritizeDeadlines = 'prioritize_deadlines';
  static const String keyInheritProjectDeadline = 'inherit_project_deadline';
  static const String keyThemeMode = 'theme_mode';
  static const String keyUseSystemColor = 'use_system_color';
}
