import 'package:intl/intl.dart';

abstract final class DatePatterns {
  static const day = 'd MMM yyyy';
  static const time = 'h:mm a';
  static const weekdayDay = 'E d MMM yyyy';
  static const attendanceDisplay = 'E d MMM yyyy HH:mm:ss';
  static const attendanceDocId = 'yyyy-MM-dd HH:mm:ss';
  static const weekday = 'EEEE';
  static const shortWeekday = 'E';
  static const shortMonth = 'MMM';
  static const month = 'MMMM';
  static const monthYear = 'MMMM yyyy';
}

const _locale = 'en_US';

final _day = DateFormat(DatePatterns.day, _locale);
final _time = DateFormat(DatePatterns.time, _locale);
final _weekdayDay = DateFormat(DatePatterns.weekdayDay, _locale);
final _attendanceDisplay = DateFormat(DatePatterns.attendanceDisplay, _locale);
final _attendanceDocId = DateFormat(DatePatterns.attendanceDocId, _locale);
final _weekday = DateFormat(DatePatterns.weekday, _locale);
final _shortWeekday = DateFormat(DatePatterns.shortWeekday, _locale);
final _shortMonth = DateFormat(DatePatterns.shortMonth, _locale);
final _month = DateFormat(DatePatterns.month, _locale);
final _monthYear = DateFormat(DatePatterns.monthYear, _locale);
final _longDate = DateFormat.yMMMMd(_locale);
final _dashboardStamp = DateFormat.yMMMMd(_locale).add_Hm();

// intl >= 0.19 emits U+202F before AM/PM; source data uses a plain space.
final _specialSpaces =
    RegExp('[${String.fromCharCode(0x202F)}${String.fromCharCode(0x00A0)}]');

String formatDay(DateTime date) => _day.format(date);

DateTime? parseDay(String? value) => _parse(_day, value);

String formatTime(DateTime time) => _time.format(time);

DateTime? parseTime(String? value) => _parse(_time, value);

String formatWeekdayDay(DateTime date) => _weekdayDay.format(date);

String attendanceDocId(DateTime timestamp) =>
    _attendanceDocId.format(timestamp);

DateTime? parseAttendanceDocId(String? value) =>
    _parse(_attendanceDocId, value);

String attendanceDisplay(DateTime timestamp) =>
    _attendanceDisplay.format(timestamp);

DateTime? parseAttendanceDisplay(String? value) =>
    _parse(_attendanceDisplay, value);

String formatLongDate(DateTime date) => _longDate.format(date);

String formatDashboardStamp(DateTime timestamp) =>
    _dashboardStamp.format(timestamp);

String formatWeekday(DateTime date) => _weekday.format(date);

String formatShortWeekday(DateTime date) => _shortWeekday.format(date);

String formatShortMonth(DateTime date) => _shortMonth.format(date);

String formatMonth(DateTime date) => _month.format(date);

String formatMonthYear(DateTime date) => _monthYear.format(date);

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime combineDayAndTime(DateTime day, DateTime time) =>
    DateTime(day.year, day.month, day.day, time.hour, time.minute);

int dayDifference(DateTime a, DateTime b) =>
    DateTime.utc(a.year, a.month, a.day)
        .difference(DateTime.utc(b.year, b.month, b.day))
        .inDays;

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime? _parse(DateFormat format, String? value) {
  if (value == null) return null;
  final normalised = value.replaceAll(_specialSpaces, ' ').trim();
  if (normalised.isEmpty) return null;
  return format.tryParseStrict(normalised);
}
