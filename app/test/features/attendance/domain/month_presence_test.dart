import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/constants/status_types.dart';
import 'package:trooptrak_final_application/features/attendance/domain/entities/attendance_record.dart';
import 'package:trooptrak_final_application/features/attendance/domain/services/month_presence.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_state.dart';

import '../../../helpers/builders.dart';

void main() {
  const inCamp = ParadeState.inCamp;
  const excuse = ParadeState.excuse;
  const medical = ParadeState.medical;
  const leave = ParadeState.leave;
  const out = ParadeState.out;

  final tan = buildSoldier();
  final october = DateTime(2026, 10);
  final now = DateTime(2026, 10, 8, 9, 30);

  AttendanceRecord bookIn(DateTime at) => buildAttendance(timestamp: at);

  AttendanceRecord bookOut(DateTime at) =>
      buildAttendance(isInsideCamp: false, timestamp: at);

  final sample = [
    bookIn(DateTime(2026, 9, 27, 21, 58, 30)),
    bookOut(DateTime(2026, 10, 2, 17, 35, 52)),
    bookIn(DateTime(2026, 10, 4, 21, 41, 7)),
  ];

  Status octoberStatus(
    String type,
    int from,
    int to, {
    String soldierId = 'Tan Ah Kow',
  }) =>
      buildStatus(
        id: '$type $from',
        soldierId: soldierId,
        type: type,
        start: DateTime(2026, 10, from),
        end: DateTime(2026, 10, to),
      );

  List<AttendanceRecord> linked(Status status) => [
        for (final link in status.linkedAttendance)
          buildAttendance(isInsideCamp: link.isInsideCamp, timestamp: link.at),
      ];

  List<ParadeState?> octoberOf(List<ParadeState?> reached) => [
        ...reached,
        ...List<ParadeState?>.filled(31 - reached.length, null),
      ];

  MonthPresence presenceOf({
    Soldier? soldier,
    Iterable<AttendanceRecord> records = const [],
    Iterable<Status> statuses = const [],
    DateTime? month,
    DateTime? at,
  }) =>
      monthPresence(
        soldier: soldier ?? tan,
        records: records,
        statuses: statuses,
        month: month ?? october,
        now: at ?? now,
      );

  group('shape', () {
    test('has one entry per day of the month, leap years included', () {
      final lengths = {
        DateTime(2026, 10): 31,
        DateTime(2026, 9): 30,
        DateTime(2026, 12): 31,
        DateTime(2026, 2): 28,
        DateTime(2024, 2): 29,
        DateTime(2000, 2): 29,
        DateTime(2100, 2): 28,
      };
      lengths.forEach((month, length) {
        expect(presenceOf(month: month).days, hasLength(length),
            reason: '$month');
      });
    });

    test('any date in the month selects it', () {
      expect(presenceOf(month: DateTime(2026, 10, 31, 23, 59)),
          presenceOf(month: DateTime(2026, 10, 1)));
    });

    test('a month fully in the future is all null', () {
      final november = presenceOf(month: DateTime(2026, 11));
      expect(november.days, List<ParadeState?>.filled(30, null));
      expect(november.elapsed, 0);
      expect(november.inCampDays, 0);
      expect(presenceOf(month: DateTime(2027, 1)).days, everyElement(isNull));
    });

    test('a month fully in the past has no null day', () {
      final september = presenceOf(month: DateTime(2026, 9));
      expect(september.days, hasLength(30));
      expect(september.days, everyElement(isNotNull));
      expect(presenceOf(month: DateTime(2025, 12)).elapsed, 31);
    });

    test('days after today are null and today is not', () {
      expect(presenceOf(at: DateTime(2026, 10, 1)).days, octoberOf([inCamp]));
      expect(presenceOf(at: DateTime(2026, 10, 8, 23, 59)).elapsed, 8);
      expect(presenceOf(at: DateTime(2026, 10, 31, 23, 59)).elapsed, 31);
      expect(presenceOf(at: DateTime(2026, 11, 1)).elapsed, 31);
    });
  });

  group('profile month strip', () {
    test('the mockup sample without statuses', () {
      expect(
        presenceOf(records: sample).days,
        octoberOf([inCamp, inCamp, out, out, inCamp, inCamp, inCamp, inCamp]),
      );
    });

    test('the mockup sample with an Excuse on 5 to 8 Oct', () {
      final statuses = [octoberStatus(StatusTypes.excuse, 5, 8)];
      expect(
        presenceOf(records: sample, statuses: statuses).days,
        octoberOf([inCamp, inCamp, out, out, excuse, excuse, excuse, excuse]),
      );
    });
  });

  group('presence reading time', () {
    test('a daily commuter shows in on every day', () {
      final commuter = [
        for (var day = 1; day <= 8; day++) ...[
          bookIn(DateTime(2026, 10, day, 7)),
          bookOut(DateTime(2026, 10, day, 18)),
        ],
      ];
      expect(presenceOf(records: commuter).days,
          octoberOf(List.filled(8, inCamp)));
    });

    test('Sunday-night in and Friday-evening out give Monday to Friday in', () {
      final september = [
        for (final friday in [4, 11, 18, 25])
          bookOut(DateTime(2026, 9, friday, 17, 35)),
        for (final sunday in [6, 13, 20, 27])
          bookIn(DateTime(2026, 9, sunday, 21, 40)),
      ];
      expect(presenceOf(month: DateTime(2026, 9), records: september).days, [
        for (var day = 1; day <= 30; day++)
          DateTime(2026, 9, day).weekday >= DateTime.saturday ? out : inCamp,
      ]);
    });

    test('a book-in in the evening only counts from the next day', () {
      final days = presenceOf(
        soldier: buildSoldier(isInCamp: false),
        records: [bookIn(DateTime(2026, 10, 4, 21, 41))],
      ).days;
      expect(days[3], out);
      expect(days[4], inCamp);
    });

    test('a booking at noon counts for that day and one minute later does not',
        () {
      expect(presenceOf(records: [bookOut(DateTime(2026, 10, 3, 12))]).days[2],
          out);
      expect(
          presenceOf(records: [bookOut(DateTime(2026, 10, 3, 12, 1))]).days[2],
          inCamp);
    });

    test('today follows now, before and after a booking', () {
      final records = [
        bookOut(DateTime(2026, 10, 7, 18)),
        bookIn(DateTime(2026, 10, 8, 7)),
        bookOut(DateTime(2026, 10, 8, 18)),
      ];
      ParadeState? todayAt(DateTime at) =>
          presenceOf(records: records, at: at).days[7];

      expect(todayAt(DateTime(2026, 10, 8, 6, 59)), out);
      expect(todayAt(DateTime(2026, 10, 8, 7)), inCamp);
      expect(todayAt(DateTime(2026, 10, 8, 17, 59)), inCamp);
      expect(todayAt(DateTime(2026, 10, 8, 18)), out);
    });

    test('the order of the records does not matter', () {
      expect(presenceOf(records: sample.reversed), presenceOf(records: sample));
    });
  });

  group('without a record to read', () {
    test('every reached day uses the stored presence', () {
      expect(presenceOf().days, octoberOf(List.filled(8, inCamp)));
      expect(presenceOf(soldier: buildSoldier(isInCamp: false)).days,
          octoberOf(List.filled(8, out)));
    });

    test('days before the first record use the stored presence', () {
      final firstRecord = [bookIn(DateTime(2026, 10, 5, 21, 41))];
      expect(
        presenceOf(soldier: buildSoldier(isInCamp: false), records: firstRecord)
            .days,
        octoberOf([out, out, out, out, out, inCamp, inCamp, inCamp]),
      );
      expect(
        presenceOf(records: [bookOut(DateTime(2026, 10, 5, 21, 41))]).days,
        octoberOf([inCamp, inCamp, inCamp, inCamp, inCamp, out, out, out]),
      );
    });
  });

  group('statuses', () {
    test('Leave with its linked book-out at 00:30 and book-in at 22:00', () {
      final status = octoberStatus(StatusTypes.leave, 5, 7);
      final records = [
        bookIn(DateTime(2026, 9, 27, 21, 58)),
        ...linked(status)
      ];

      expect(presenceOf(records: records).days,
          octoberOf([inCamp, inCamp, inCamp, inCamp, out, out, out, inCamp]));
      expect(
        presenceOf(records: records, statuses: [status]).days,
        octoberOf(
            [inCamp, inCamp, inCamp, inCamp, leave, leave, leave, inCamp]),
      );
    });

    test('Leave without linked records still shows', () {
      final statuses = [octoberStatus(StatusTypes.leave, 5, 7)];
      expect(
        presenceOf(statuses: statuses).days,
        octoberOf(
            [inCamp, inCamp, inCamp, inCamp, leave, leave, leave, inCamp]),
      );
    });

    test('a single-day Medical Appointment is medical that day only', () {
      final status = octoberStatus(StatusTypes.medicalAppointment, 6, 6);
      expect(
        presenceOf(records: linked(status), statuses: [status]).days,
        octoberOf(
            [inCamp, inCamp, inCamp, inCamp, inCamp, medical, inCamp, inCamp]),
      );
    });

    test('an Excuse shows while in camp and gives way to out when booked out',
        () {
      final statuses = [octoberStatus(StatusTypes.excuse, 1, 8)];
      expect(
        presenceOf(records: sample, statuses: statuses).days,
        octoberOf([excuse, excuse, out, out, excuse, excuse, excuse, excuse]),
      );
    });

    test('Leave beats Medical Appointment beats Excuse on the same day', () {
      final statuses = [
        octoberStatus(StatusTypes.excuse, 5, 8),
        octoberStatus(StatusTypes.medicalAppointment, 6, 7),
        octoberStatus(StatusTypes.leave, 7, 7),
      ];
      expect(
        presenceOf(statuses: statuses).days,
        octoberOf(
            [inCamp, inCamp, inCamp, inCamp, excuse, medical, leave, excuse]),
      );
    });

    test('statuses of other soldiers are ignored', () {
      final statuses = [
        octoberStatus(StatusTypes.leave, 5, 7, soldierId: 'Lee'),
      ];
      expect(presenceOf(statuses: statuses).days,
          octoberOf(List.filled(8, inCamp)));
    });

    test('a status shows on its own days only', () {
      final statuses = [octoberStatus(StatusTypes.leave, 3, 4)];
      expect(
        presenceOf(statuses: statuses).days,
        octoberOf(
            [inCamp, inCamp, leave, leave, inCamp, inCamp, inCamp, inCamp]),
      );
    });

    test('a status that began last month shows from day 1', () {
      final statuses = [
        buildStatus(
          type: StatusTypes.leave,
          start: DateTime(2026, 9, 28),
          end: DateTime(2026, 10, 2),
        ),
      ];
      expect(
        presenceOf(statuses: statuses).days,
        octoberOf(
            [leave, leave, inCamp, inCamp, inCamp, inCamp, inCamp, inCamp]),
      );
    });

    test('a status starting after today is not shown yet', () {
      final statuses = [octoberStatus(StatusTypes.excuse, 9, 12)];
      expect(presenceOf(statuses: statuses).days,
          octoberOf(List.filled(8, inCamp)));
    });

    test('a status running past today shows up to today only', () {
      final statuses = [octoberStatus(StatusTypes.excuse, 7, 12)];
      expect(
        presenceOf(statuses: statuses).days,
        octoberOf(
            [inCamp, inCamp, inCamp, inCamp, inCamp, inCamp, excuse, excuse]),
      );
    });
  });

  group('counts', () {
    test('elapsed counts reached days and in camp counts inCamp and excuse',
        () {
      const presence = MonthPresence(
          [inCamp, excuse, medical, leave, out, inCamp, null, null]);
      expect(presence.elapsed, 6);
      expect(presence.inCampDays, 3);
    });

    test('nothing reached counts nothing', () {
      const presence = MonthPresence([null, null]);
      expect(presence.elapsed, 0);
      expect(presence.inCampDays, 0);
    });

    test('the mockup sample is 6 of 8 days, with or without the Excuse', () {
      final plain = presenceOf(records: sample);
      final excused = presenceOf(
        records: sample,
        statuses: [octoberStatus(StatusTypes.excuse, 5, 8)],
      );
      for (final presence in [plain, excused]) {
        expect(presence.elapsed, 8);
        expect(presence.inCampDays, 6);
      }
    });

    test('Leave days are not in camp', () {
      final status = octoberStatus(StatusTypes.leave, 5, 7);
      final presence = presenceOf(records: linked(status), statuses: [status]);
      expect(presence.elapsed, 8);
      expect(presence.inCampDays, 5);
    });
  });

  group('equality', () {
    test('month presences compare by value', () {
      expect(presenceOf(records: sample), presenceOf(records: sample));
      expect(presenceOf(records: sample).hashCode,
          presenceOf(records: sample).hashCode);
      expect(presenceOf(records: sample), isNot(presenceOf()));
      expect(presenceOf(), isNot(presenceOf(at: DateTime(2026, 10, 9))));
    });
  });
}
