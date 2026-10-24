/// The range the conduct form's date picker allows: from 2022 to a year ahead.
abstract final class ConductDateLimits {
  static final earliest = DateTime(2022);

  static DateTime latest(DateTime today) =>
      DateTime(today.year + 1, today.month, today.day);
}
