/// The range the profile form's date pickers allow.
abstract final class ProfileDateLimits {
  static final earliest = DateTime(1960);
  static final latest = DateTime(2100);

  static DateTime latestBirth(DateTime today) => today;
}
