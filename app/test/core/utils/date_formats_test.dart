import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/utils/date_formats.dart';

void main() {
  final sample = DateTime(2023, 7, 5, 17, 30, 9);

  group('day format d MMM yyyy', () {
    test('formats and round-trips', () {
      expect(formatDay(sample), '5 Jul 2023');
      expect(parseDay('5 Jul 2023'), DateTime(2023, 7, 5));
      expect(
          parseDay(formatDay(DateTime(2024, 12, 31))), DateTime(2024, 12, 31));
    });

    test('invalid strings return null', () {
      expect(parseDay(null), isNull);
      expect(parseDay(''), isNull);
      expect(parseDay('not a date'), isNull);
      expect(parseDay('2023-07-05'), isNull);
      expect(parseDay('31 Feb 2023'), isNull);
    });
  });

  group('time format jm', () {
    test('uses a plain space before AM/PM like the source data', () {
      expect(formatTime(sample), '5:30 PM');
      expect(formatTime(DateTime(2023, 1, 1, 9, 5)), '9:05 AM');
    });

    test('parses plain and narrow no-break space variants', () {
      final plain = parseTime('5:30 PM')!;
      final narrow = parseTime('5:30${String.fromCharCode(0x202F)}PM')!;
      expect([plain.hour, plain.minute], [17, 30]);
      expect([narrow.hour, narrow.minute], [17, 30]);
    });

    test('invalid strings return null', () {
      expect(parseTime('25:99'), isNull);
      expect(parseTime('noon'), isNull);
    });
  });

  group('attendance formats', () {
    test('doc id yyyy-MM-dd HH:mm:ss round-trips', () {
      expect(attendanceDocId(sample), '2023-07-05 17:30:09');
      expect(parseAttendanceDocId('2023-07-05 17:30:09'), sample);
      expect(parseAttendanceDocId('5 Jul 2023'), isNull);
    });

    test('display E d MMM yyyy HH:mm:ss round-trips', () {
      expect(attendanceDisplay(sample), 'Wed 5 Jul 2023 17:30:09');
      expect(parseAttendanceDisplay('Wed 5 Jul 2023 17:30:09'), sample);
      expect(parseAttendanceDisplay('garbage'), isNull);
    });
  });

  test('display-only formats', () {
    expect(formatWeekdayDay(sample), 'Wed 5 Jul 2023');
    expect(formatLongDate(sample), 'July 5, 2023');
    expect(formatDashboardStamp(sample), 'July 5, 2023 17:30');
    expect(formatWeekday(sample), 'Wednesday');
    expect(formatShortWeekday(sample), 'Wed');
    expect(formatShortMonth(sample), 'Jul');
    expect(formatMonth(sample), 'July');
    expect(formatMonthYear(sample), 'July 2023');
  });

  group('dayDifference', () {
    test('ignores time of day', () {
      expect(
          dayDifference(
              DateTime(2023, 7, 6, 0, 1), DateTime(2023, 7, 5, 23, 59)),
          1);
      expect(
          dayDifference(DateTime(2023, 7, 5, 23), DateTime(2023, 7, 5, 1)), 0);
    });

    test('is signed', () {
      expect(dayDifference(DateTime(2023, 7, 1), DateTime(2023, 7, 5)), -4);
    });

    test('crosses month and year boundaries', () {
      expect(dayDifference(DateTime(2023, 3, 1), DateTime(2023, 2, 28)), 1);
      expect(dayDifference(DateTime(2024, 3, 1), DateTime(2024, 2, 28)), 2);
      expect(dayDifference(DateTime(2024, 1, 1), DateTime(2023, 12, 31)), 1);
      expect(dayDifference(DateTime(2024, 1, 1), DateTime(2023, 1, 1)), 365);
    });

    test('is not affected by DST transitions', () {
      expect(dayDifference(DateTime(2026, 3, 9), DateTime(2026, 3, 8)), 1);
      expect(dayDifference(DateTime(2026, 3, 30), DateTime(2026, 3, 29)), 1);
      expect(dayDifference(DateTime(2026, 11, 2), DateTime(2026, 11, 1)), 1);
      expect(dayDifference(DateTime(2026, 10, 26), DateTime(2026, 10, 25)), 1);
    });
  });

  test('isSameDay, dateOnly and combineDayAndTime', () {
    expect(
        isSameDay(DateTime(2023, 7, 5, 1), DateTime(2023, 7, 5, 23)), isTrue);
    expect(isSameDay(DateTime(2023, 7, 5), DateTime(2023, 7, 6)), isFalse);
    expect(isSameDay(DateTime(2023, 7, 5), DateTime(2024, 7, 5)), isFalse);
    expect(dateOnly(sample), DateTime(2023, 7, 5));
    expect(
      combineDayAndTime(DateTime(2023, 7, 5), DateTime(1970, 1, 1, 17, 30)),
      DateTime(2023, 7, 5, 17, 30),
    );
  });
}
