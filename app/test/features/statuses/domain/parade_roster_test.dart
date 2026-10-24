import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/constants/status_types.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_roster.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_state.dart';

import '../../../helpers/builders.dart';

void main() {
  final today = DateTime(2023, 7, 5, 9);
  final tan = buildSoldier(name: 'Tan');
  final lee = buildSoldier(name: 'Lee', isInCamp: false);
  final lim = buildSoldier(name: 'Lim');

  Status statusOf(
    String id, {
    String soldierId = 'Tan',
    String type = StatusTypes.excuse,
    DateTime? start,
    DateTime? end,
  }) =>
      buildStatus(
          id: id, soldierId: soldierId, type: type, start: start, end: end);

  List<Status> currentOf(List<Status> statuses) =>
      paradeRoster([tan], statuses, today).single.statuses;

  group('current statuses (R3)', () {
    final status =
        statusOf('s', start: DateTime(2023, 7, 3), end: DateTime(2023, 7, 5));

    List<Status> currentOn(DateTime day) =>
        paradeRoster([tan], [status], day).single.statuses;

    test('a status counts from its start day through its end day', () {
      expect(currentOn(DateTime(2023, 7, 2, 23, 59)), isEmpty);
      expect(currentOn(DateTime(2023, 7, 3)), [status]);
      expect(currentOn(DateTime(2023, 7, 5, 22)), [status]);
      expect(currentOn(DateTime(2023, 7, 6)), isEmpty);
    });

    test('a status starting and ending today counts', () {
      final oneDay =
          statusOf('d', start: DateTime(2023, 7, 5), end: DateTime(2023, 7, 5));
      expect(currentOf([oneDay]), [oneDay]);
    });

    test('a status that has not started or has ended is ignored', () {
      final ended = statusOf('a', end: DateTime(2023, 7, 4));
      final future =
          statusOf('b', start: DateTime(2023, 7, 6), end: DateTime(2023, 7, 8));
      final entry = paradeRoster([tan], [ended, future], today).single;
      expect(entry.statuses, isEmpty);
      expect(entry.status, isNull);
      expect(entry.state, ParadeState.inCamp);
    });
  });

  group('primary status', () {
    final excuse = statusOf('ex');
    final medical = statusOf('ma', type: StatusTypes.medicalAppointment);
    final leave = statusOf('lv', type: StatusTypes.leave);

    test('Leave, then Medical Appointment, then Excuse, in any input order',
        () {
      for (final input in [
        [excuse, medical, leave],
        [leave, medical, excuse],
        [medical, leave, excuse],
      ]) {
        final entry = paradeRoster([tan], input, today).single;
        expect(entry.statuses, [leave, medical, excuse]);
        expect(entry.status, leave);
      }
    });

    test('the type outranks the end date', () {
      final longExcuse = statusOf('ex', end: DateTime(2023, 7, 20));
      final shortLeave =
          statusOf('lv', type: StatusTypes.leave, end: DateTime(2023, 7, 5));
      expect(currentOf([longExcuse, shortLeave]), [shortLeave, longExcuse]);
    });

    test('within a type the status that ends last comes first', () {
      final short = statusOf('a', end: DateTime(2023, 7, 6));
      final long = statusOf('b', end: DateTime(2023, 7, 9));
      expect(currentOf([short, long]), [long, short]);
      expect(currentOf([long, short]), [long, short]);
    });

    test('equal ends keep the input order', () {
      final first = statusOf('a');
      final second = statusOf('b');
      expect(currentOf([first, second]), [first, second]);
      expect(currentOf([second, first]), [second, first]);
    });

    test('an unknown type ranks after the known ones', () {
      final other = statusOf('o', type: 'Other', end: DateTime(2023, 7, 20));
      expect(currentOf([other, excuse]), [excuse, other]);
    });

    test('a status that is not current never becomes the primary', () {
      final endedLeave = statusOf('lv',
          type: StatusTypes.leave,
          start: DateTime(2023, 6, 1),
          end: DateTime(2023, 6, 3));
      expect(paradeRoster([tan], [endedLeave, excuse], today).single.status,
          excuse);
    });
  });

  group('state', () {
    ParadeState stateOf(List<String> types, {bool inCamp = true}) =>
        paradeRoster(
          [buildSoldier(name: 'Tan', isInCamp: inCamp)],
          [
            for (final (i, type) in types.indexed) statusOf('s$i', type: type),
          ],
          today,
        ).single.state;

    const excuse = StatusTypes.excuse;
    const medical = StatusTypes.medicalAppointment;
    const leave = StatusTypes.leave;

    test('without a current status the booked-in flag decides', () {
      expect(stateOf(const []), ParadeState.inCamp);
      expect(stateOf(const [], inCamp: false), ParadeState.out);
    });

    test('Leave and Medical Appointment override the flag', () {
      expect(stateOf(const [leave]), ParadeState.leave);
      expect(stateOf(const [leave], inCamp: false), ParadeState.leave);
      expect(stateOf(const [medical]), ParadeState.medical);
      expect(stateOf(const [medical], inCamp: false), ParadeState.medical);
    });

    test('an Excuse only shows while in camp', () {
      expect(stateOf(const [excuse]), ParadeState.excuse);
      expect(stateOf(const [excuse], inCamp: false), ParadeState.out);
    });

    test('the state follows the primary status', () {
      expect(stateOf(const [excuse, leave]), ParadeState.leave);
      expect(stateOf(const [excuse, medical]), ParadeState.medical);
      expect(stateOf(const [medical, leave]), ParadeState.leave);
      expect(
          stateOf(const [excuse, medical], inCamp: false), ParadeState.medical);
    });

    test('only in camp and excuse count as in camp', () {
      expect({
        for (final state in ParadeState.values) state: state.isInCamp
      }, {
        ParadeState.inCamp: true,
        ParadeState.excuse: true,
        ParadeState.medical: false,
        ParadeState.leave: false,
        ParadeState.out: false,
      });
    });
  });

  group('roster', () {
    test('soldiers keep their input order, each with their own statuses', () {
      final limLeave = statusOf('lv', soldierId: 'Lim', type: 'Leave');
      final tanExcuse = statusOf('ex');
      final stranger = statusOf('x', soldierId: 'Nobody');
      final entries =
          paradeRoster([lim, lee, tan], [tanExcuse, stranger, limLeave], today);

      expect(entries.map((e) => e.soldier), [lim, lee, tan]);
      expect(entries.map((e) => e.statuses), [
        [limLeave],
        isEmpty,
        [tanExcuse],
      ]);
      expect(entries.map((e) => e.state),
          [ParadeState.leave, ParadeState.out, ParadeState.excuse]);
    });

    test('soldiers without statuses are still listed', () {
      final entries = paradeRoster([tan, lee], const [], today);
      expect(entries.map((e) => e.soldier), [tan, lee]);
      expect(entries.map((e) => e.status), [isNull, isNull]);
      expect(
          entries.map((e) => e.state), [ParadeState.inCamp, ParadeState.out]);
    });

    test('no soldiers give an empty roster', () {
      expect(paradeRoster(const [], [statusOf('ex')], today), isEmpty);
    });

    test('entries compare by value', () {
      final leave = statusOf('lv', type: StatusTypes.leave);
      final entry = ParadeEntry(
          soldier: tan, statuses: [leave], state: ParadeState.leave);
      expect(
          entry,
          ParadeEntry(
              soldier: tan, statuses: [leave], state: ParadeState.leave));
      expect(
          entry,
          isNot(ParadeEntry(
              soldier: tan, statuses: const [], state: ParadeState.inCamp)));
    });
  });
}
