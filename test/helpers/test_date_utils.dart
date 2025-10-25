/// Test date utility helpers to avoid hard-coded dates in tests.
///
/// Using DateTime.now() with relative calculations ensures tests remain valid
/// over time and don't fail due to hard-coded dates becoming outdated.
library;

/// Get base date for tests - uses current date to avoid hard-coding.
/// All relative dates in tests should derive from this.
DateTime get testBaseDate => DateTime.now();

/// Get a date relative to today (negative for past, positive for future)
DateTime daysAgo(int days) => testBaseDate.subtract(Duration(days: days));

/// Get a date in the future
DateTime daysFromNow(int days) => testBaseDate.add(Duration(days: days));

/// Get a specific time on a relative date
DateTime dateWithTime(
  int daysOffset,
  int hour, [
  int minute = 0,
  int second = 0,
]) {
  final date = daysOffset < 0 ? daysAgo(-daysOffset) : daysFromNow(daysOffset);
  return DateTime(date.year, date.month, date.day, hour, minute, second);
}

/// Get a time on today's date
DateTime todayAt(int hour, [int minute = 0]) {
  final now = testBaseDate;
  return DateTime(now.year, now.month, now.day, hour, minute);
}

/// Get midnight today
DateTime get today {
  final now = testBaseDate;
  return DateTime(now.year, now.month, now.day);
}

/// Get midnight yesterday
DateTime get yesterday => daysAgo(1);

/// Get midnight tomorrow
DateTime get tomorrow => daysFromNow(1);

/// Get the end of day (23:59:59.999) for a given date offset
DateTime endOfDay(int daysOffset) {
  final date = daysOffset < 0 ? daysAgo(-daysOffset) : daysFromNow(daysOffset);
  return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}

/// Get the end of today (23:59:59.999)
DateTime get endOfToday => endOfDay(0);

/// Get a date N hours ago
DateTime hoursAgo(int hours) => testBaseDate.subtract(Duration(hours: hours));

/// Get a date N hours from now
DateTime hoursFromNow(int hours) => testBaseDate.add(Duration(hours: hours));

/// Get a date N minutes ago
DateTime minutesAgo(int minutes) =>
    testBaseDate.subtract(Duration(minutes: minutes));

/// Get a date N minutes from now
DateTime minutesFromNow(int minutes) =>
    testBaseDate.add(Duration(minutes: minutes));
