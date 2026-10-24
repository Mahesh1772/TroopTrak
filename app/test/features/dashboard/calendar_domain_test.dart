import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/entities/calendar_event.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/services/month_grid.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/usecases/watch_calendar_events.dart';

CalendarEvent event(
  String title,
  DateTime start,
  DateTime end, [
  CalendarEventKind kind = CalendarEventKind.conduct,
]) =>
    CalendarEvent(title: title, start: start, end: end, kind: kind);

void main() {
  group('eventsOn', () {
    final day = DateTime(2026, 10, 8);

    test('orders by start, then conducts before duties, then by title', () {
      final duty = event('Guard Duty', DateTime(2026, 10, 8, 8),
          DateTime(2026, 10, 9, 8), CalendarEventKind.guardDuty);
      final ippt = event(
          'IPPT Window 3', DateTime(2026, 10, 8, 8), DateTime(2026, 10, 8, 10));
      final alpha = event(
          'Alpha Run', DateTime(2026, 10, 8, 8), DateTime(2026, 10, 8, 9));
      final early =
          event('Warm up', DateTime(2026, 10, 8, 6), DateTime(2026, 10, 8, 7));
      final other =
          event('Tomorrow', DateTime(2026, 10, 9, 6), DateTime(2026, 10, 9, 7));

      expect(eventsOn([duty, ippt, other, alpha, early], day),
          [early, alpha, ippt, duty]);
    });

    test('a multi-day duty is listed on its start day only', () {
      final duty = event('Guard Duty', DateTime(2026, 10, 8, 8),
          DateTime(2026, 10, 9, 8), CalendarEventKind.guardDuty);
      expect(eventsOn([duty], DateTime(2026, 10, 9)), isEmpty);
    });
  });

  group('dotKindsOn', () {
    final conduct =
        event('Run', DateTime(2026, 10, 8, 7), DateTime(2026, 10, 8, 8));
    final duty = event('Guard Duty', DateTime(2026, 10, 8, 8),
        DateTime(2026, 10, 9, 8), CalendarEventKind.guardDuty);
    final day = DateTime(2026, 10, 8);

    test('one dot per kind in legend order, however many events', () {
      expect(dotKindsOn([duty, conduct, conduct], day),
          [CalendarEventKind.conduct, CalendarEventKind.guardDuty]);
    });

    test('a single kind gives a single dot', () {
      expect(dotKindsOn([duty], day), [CalendarEventKind.guardDuty]);
    });

    test('a day without events has none', () {
      expect(dotKindsOn([conduct, duty], DateTime(2026, 10, 7)), isEmpty);
    });
  });

  group('endsNextDay', () {
    test('false when the end is on the start day', () {
      expect(
          event('Run', DateTime(2026, 10, 8, 7), DateTime(2026, 10, 8, 8))
              .endsNextDay,
          isFalse);
    });

    test('true when the end is on a later day', () {
      expect(
          event('Guard Duty', DateTime(2026, 10, 8, 8),
                  DateTime(2026, 10, 9, 8))
              .endsNextDay,
          isTrue);
    });

    test('an end normalised by endFor at the same clock time is next day', () {
      final start = DateTime(2026, 10, 8, 8);
      expect(
          event('Guard Duty', start, CalendarEvent.endFor(start, start))
              .endsNextDay,
          isTrue);
    });
  });

  group('monthWeeks', () {
    test('July 2023 starts on a Saturday and ends on a Monday', () {
      final weeks = monthWeeks(DateTime(2023, 7));
      expect(weeks, hasLength(6));
      expect(weeks.every((w) => w.length == 7), isTrue);
      expect(weeks.first.first.date, DateTime(2023, 6, 26));
      expect(weeks.first.first.inMonth, isFalse);
      expect(weeks.first[5], MonthCell(DateTime(2023, 7), inMonth: true));
      expect(weeks.last.first, MonthCell(DateTime(2023, 7, 31), inMonth: true));
      expect(weeks.last.last, MonthCell(DateTime(2023, 8, 6), inMonth: false));
    });

    test('October 2026 matches the mockup: 28 Sep to 1 Nov', () {
      final cells = monthWeeks(DateTime(2026, 10)).expand((w) => w).toList();
      expect(cells, hasLength(35));
      expect(cells.first, MonthCell(DateTime(2026, 9, 28), inMonth: false));
      expect(cells.last, MonthCell(DateTime(2026, 11), inMonth: false));
      expect(cells.where((c) => c.inMonth), hasLength(31));
    });

    test('a month that fills whole weeks has no neighbouring days', () {
      final cells = monthWeeks(DateTime(2027, 2)).expand((w) => w).toList();
      expect(cells, hasLength(28));
      expect(cells.every((c) => c.inMonth), isTrue);
    });

    test('a leap February and a year boundary', () {
      final feb = monthWeeks(DateTime(2024, 2)).expand((w) => w).toList();
      expect(feb.where((c) => c.inMonth), hasLength(29));
      final dec = monthWeeks(DateTime(2025, 12)).expand((w) => w).toList();
      expect(dec.last, MonthCell(DateTime(2026, 1, 4), inMonth: false));
    });
  });
}
