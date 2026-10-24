/// Rules of the duty form. The messages are the source's own texts.
abstract final class DutyValidators {
  static String? date<T>(T? value) =>
      value == null ? 'Select a duty date' : null;

  static String? startTime<T>(T? value) =>
      value == null ? 'Select a start time' : null;

  static String? endTime<T>(T? value) =>
      value == null ? 'Select an end time' : null;
}
