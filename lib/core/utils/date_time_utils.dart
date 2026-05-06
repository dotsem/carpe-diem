import 'package:carpe_diem/core/constants/app_constants.dart';

/*
Returns true if the date is Friday, Saturday, or Sunday.
*/
bool isEndOfWorkWeek(DateTime date) {
  if (date.weekday == DateTime.friday || date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    return true;
  }
  return false;
}

bool todayIsEndOfWorkWeek() {
  return isEndOfWorkWeek(DateTime.now());
}

extension DateTimeExtension on DateTime {
  DateTime next(int day) {
    if (day == weekday) {
      return add(const Duration(days: 7));
    } else {
      return add(Duration(days: (day - weekday) % DateTime.daysPerWeek));
    }
  }

  DateTime get startOfNextWeek => next(AppConstants.firstDayOfWeek);

  DateTime get startOfWeek {
    int dayOffset = (weekday - AppConstants.firstDayOfWeek) % DateTime.daysPerWeek;
    return DateTime(year, month, day).subtract(Duration(days: dayOffset));
  }

  bool get isStartOfWeek => weekday == AppConstants.firstDayOfWeek;

  bool isSameDay(DateTime? other) {
    if (other == null) return false;
    return year == other.year && month == other.month && day == other.day;
  }

  bool isBeforeDay(DateTime? other) {
    if (other == null) return false;
    return year < other.year ||
        (year == other.year && (month < other.month || (month == other.month && day < other.day)));
  }

  bool isAfterDay(DateTime? other) {
    if (other == null) return false;
    return year > other.year ||
        (year == other.year && (month > other.month || (month == other.month && day > other.day)));
  }

  DateTime startOfMonth() => DateTime(year, month, 1);
  DateTime endOfMonth() => DateTime(year, month + 1, 0);

  bool isBetween(DateTime start, DateTime end) {
    return (isAfterDay(start) || isSameDay(start)) && (isBeforeDay(end) || isSameDay(end));
  }
}
