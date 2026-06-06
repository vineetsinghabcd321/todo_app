enum TaskDateCategory { yesterday, today, future }

class DateUtilsHelper {
  static DateTime normalize(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static bool isBeforeToday(DateTime value, {DateTime? referenceDate}) {
    return normalize(
      value,
    ).isBefore(normalize(referenceDate ?? DateTime.now()));
  }

  static bool isToday(DateTime value, {DateTime? referenceDate}) {
    return isSameDay(value, referenceDate ?? DateTime.now());
  }

  static bool isAfterToday(DateTime value, {DateTime? referenceDate}) {
    return normalize(value).isAfter(normalize(referenceDate ?? DateTime.now()));
  }

  static TaskDateCategory categorize(
    DateTime value, {
    DateTime? referenceDate,
  }) {
    final normalizedValue = normalize(value);
    final normalizedToday = normalize(referenceDate ?? DateTime.now());

    if (normalizedValue.isBefore(normalizedToday)) {
      return TaskDateCategory.yesterday;
    }

    if (isSameDay(normalizedValue, normalizedToday)) {
      return TaskDateCategory.today;
    }

    return TaskDateCategory.future;
  }

  static String formatDateKey(DateTime value) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${value.day.toString().padLeft(2, '0')} ${monthNames[value.month - 1]} ${value.year}';
  }

  static bool isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
