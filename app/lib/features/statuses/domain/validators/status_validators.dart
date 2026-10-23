import '../../../../core/utils/date_formats.dart';

/// K18 fix: the source accepted an end date before the start date.
const endBeforeStart = 'End date cannot be before the start date.';

/// Rules of the status form. The messages are the source's own texts.
abstract final class StatusValidators {
  static String? type(String? value) =>
      value == null ? 'Bruh select Dei!' : null;

  static String? name(String? value) => (value ?? '').trim().isEmpty
      ? 'Oi can enter the status type please?'
      : null;

  /// The end day may equal the start day but not precede it.
  static String? period(DateTime start, DateTime end) =>
      dayDifference(end, start) < 0 ? endBeforeStart : null;
}
