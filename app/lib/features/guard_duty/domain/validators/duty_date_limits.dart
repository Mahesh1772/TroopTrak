/// The range the duty form's date picker allows: from 2020 to the end of next
/// year.
abstract final class DutyDateLimits {
  static final earliest = DateTime(2020);

  static DateTime latest(DateTime today) => DateTime(today.year + 1, 12, 31);
}
