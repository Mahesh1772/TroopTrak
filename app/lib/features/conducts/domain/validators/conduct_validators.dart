/// Rules of the conduct form. The messages are the source's own texts.
abstract final class ConductValidators {
  static String? type(String? value) => value == null ? 'Bruh select!' : null;

  static String? name(String? value) =>
      (value ?? '').trim().isEmpty ? 'Oi can add conduct please?' : null;

  static String? date<T>(T? value) => value == null ? 'Select a date' : null;

  static String? startTime<T>(T? value) =>
      value == null ? 'Select a start time' : null;

  static String? endTime<T>(T? value) =>
      value == null ? 'Select an end time' : null;
}
