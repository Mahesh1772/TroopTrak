import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_parade_roster.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_soldiers_in_camp.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/entities/strength_summary.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/usecases/watch_strength_summary.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/repositories/status_repository.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_roster.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_state.dart';

import '../../helpers/builders.dart';
import '../../helpers/fake_clock.dart';

class _MockSoldiers extends Mock implements WatchSoldiersInCamp {}

class _MockStatuses extends Mock implements StatusRepository {}

class _MockRoster extends Mock implements WatchParadeRoster {}

void main() {
  final today = DateTime(2023, 7, 5, 9);
  final lt = buildSoldier(name: 'Lt Lee', rank: '2LT');
  final cpt = buildSoldier(name: 'Cpt Ong', rank: 'CPT', isInCamp: false);
  final cpl = buildSoldier(name: 'Cpl Tan', rank: 'CPL');
  final sct = buildSoldier(name: 'Sct Lim', rank: 'SCT', isInCamp: false);
  final odd = buildSoldier(name: 'Odd Rank', rank: 'XYZ');
  final soldiers = [lt, cpt, cpl, sct, odd];

  StrengthSummary summaryOf(
    Iterable<Soldier> soldiers, [
    Iterable<Status> statuses = const [],
  ]) =>
      StrengthSummary(entries: paradeRoster(soldiers, statuses, today));

  List<Soldier> soldiersOf(Iterable<ParadeEntry> entries) =>
      [for (final e in entries) e.soldier];

  List<Soldier> inCamp(Iterable<ParadeEntry> entries) =>
      soldiersOf(entries.where((e) => e.state.isInCamp));

  test('officers vs WOSEs (R4) with in-camp counts; unknown ranks in neither',
      () {
    final s = summaryOf(soldiers);
    expect(soldiersOf(s.officerEntries), [lt, cpt]);
    expect(soldiersOf(s.woseEntries), [cpl, sct]);
    expect(inCamp(s.officerEntries), [lt]);
    expect(inCamp(s.woseEntries), [cpl]);
    expect(s.row(ParadeReportKind.officers).current, 1);
    expect(s.row(ParadeReportKind.woses).current, 1);
    expect(s.total, 4);
    expect(s, summaryOf(soldiers));
    expect(s, isNot(summaryOf([lt])));
  });

  test('entries keep every soldier; the group lists keep the input order', () {
    final s = summaryOf(soldiers);
    expect(s.entries.map((e) => e.soldier), soldiers);
    expect(s.officerEntries.map((e) => e.soldier), [lt, cpt]);
    expect(s.woseEntries.map((e) => e.soldier), [cpl, sct]);
  });

  group('in camp (D9)', () {
    test('booked-in soldiers count; the flag decides without a status', () {
      final s = summaryOf(soldiers);
      expect(s.inCampCount, 2);
      expect(s.count(ParadeState.inCamp), 2);
      expect(s.count(ParadeState.out), 2);
    });

    test('an excuse still counts as in camp, but only while booked in', () {
      final s = summaryOf(soldiers, [
        buildStatus(soldierId: 'Cpl Tan', name: 'Ex RMJ'),
        buildStatus(id: 's2', soldierId: 'Cpt Ong', name: 'Ex RMJ'),
      ]);
      expect(inCamp(s.woseEntries), [cpl]);
      expect(inCamp(s.officerEntries), [lt]);
      expect(s.inCampCount, 2);
      expect(s.count(ParadeState.excuse), 1);
      expect(s.count(ParadeState.out), 2);
    });

    test('leave and MA take a booked-in soldier out of the in-camp figure', () {
      final s = summaryOf(soldiers, [
        buildStatus(soldierId: 'Lt Lee', type: 'Leave', name: 'OL'),
        buildStatus(
            id: 's2',
            soldierId: 'Cpl Tan',
            type: 'Medical Appointment',
            name: 'Dental'),
      ]);
      expect(inCamp(s.officerEntries), isEmpty);
      expect(inCamp(s.woseEntries), isEmpty);
      expect(s.inCampCount, 0);
      expect(s.count(ParadeState.leave), 1);
      expect(s.count(ParadeState.medical), 1);
    });
  });

  test('per-state counts cover officers and WOSEs and add up to total', () {
    final maj = buildSoldier(name: 'Maj Goh', rank: 'MAJ');
    final pte = buildSoldier(name: 'Pte Chua', rank: 'PTE');
    final cfc = buildSoldier(name: 'Cfc Yeo', rank: 'CFC');
    final roster = [lt, maj, cpt, cpl, pte, cfc, sct, odd];
    final s = summaryOf(roster, [
      buildStatus(soldierId: 'Maj Goh', name: 'Ex RMJ'),
      buildStatus(id: 's2', soldierId: 'Cpt Ong', name: 'Ex RMJ'),
      buildStatus(
          id: 's3',
          soldierId: 'Cpl Tan',
          type: 'Medical Appointment',
          name: 'Dental'),
      buildStatus(id: 's4', soldierId: 'Pte Chua', type: 'Leave', name: 'OL'),
      buildStatus(id: 's5', soldierId: 'Odd Rank', type: 'Leave', name: 'OL'),
    ]);

    final counts = {
      for (final state in ParadeState.values) state: s.count(state)
    };
    expect(counts, {
      ParadeState.inCamp: 2,
      ParadeState.excuse: 1,
      ParadeState.medical: 1,
      ParadeState.leave: 1,
      ParadeState.out: 2,
    });
    expect(ParadeState.values.map(s.count).reduce((a, b) => a + b), s.total);
    expect(s.total, 7);
    expect(s.inCampCount, 3);
    expect(inCamp(s.officerEntries), [lt, maj]);
    expect(inCamp(s.woseEntries), [cfc]);
  });

  test('MA vs other statuses, once per soldier, started and active (R3, K3)',
      () {
    final statuses = [
      buildStatus(soldierId: 'Cpl Tan', name: 'Ex RMJ'),
      buildStatus(id: 's2', soldierId: 'Cpl Tan', type: 'Leave', name: 'OL'),
      buildStatus(
          soldierId: 'Lt Lee', type: 'Medical Appointment', name: 'Dental'),
      buildStatus(
          soldierId: 'Sct Lim',
          name: 'LD',
          start: DateTime(2023, 7, 6),
          end: DateTime(2023, 7, 8)),
      buildStatus(soldierId: 'Cpt Ong', name: 'LD', end: DateTime(2023, 7, 4)),
    ];
    final s = summaryOf(soldiers, statuses);
    expect(soldiersOf(s.row(ParadeReportKind.onStatus).entries), [cpl]);
    expect(soldiersOf(s.row(ParadeReportKind.onMa).entries), [lt]);
  });

  test('a soldier with an MA and other statuses is in each list once', () {
    final s = summaryOf(soldiers, [
      buildStatus(soldierId: 'Cpl Tan', name: 'Ex RMJ'),
      buildStatus(id: 's2', soldierId: 'Cpl Tan', name: 'LD'),
      buildStatus(
          id: 's3',
          soldierId: 'Cpl Tan',
          type: 'Medical Appointment',
          name: 'Dental'),
      buildStatus(
          id: 's4',
          soldierId: 'Cpl Tan',
          type: 'Medical Appointment',
          name: 'X-ray'),
    ]);
    expect(soldiersOf(s.row(ParadeReportKind.onStatus).entries), [cpl]);
    expect(soldiersOf(s.row(ParadeReportKind.onMa).entries), [cpl]);
  });

  test('a status starting today and ending today counts', () {
    final s = summaryOf(soldiers, [
      buildStatus(
          soldierId: 'Cpt Ong',
          start: DateTime(2023, 7, 5),
          end: DateTime(2023, 7, 5)),
    ]);
    expect(soldiersOf(s.row(ParadeReportKind.onStatus).entries), [cpt]);
  });

  group('parade report', () {
    final maj = buildSoldier(name: 'Maj Goh', rank: 'MAJ');
    final pte = buildSoldier(name: 'Pte Chua', rank: 'PTE');
    final roster = [lt, maj, cpt, cpl, pte, sct, odd];
    final statuses = [
      buildStatus(soldierId: 'Maj Goh', name: 'Ex RMJ'),
      buildStatus(id: 's2', soldierId: 'Cpt Ong', type: 'Leave', name: 'OL'),
      buildStatus(
          id: 's3',
          soldierId: 'Cpl Tan',
          type: 'Medical Appointment',
          name: 'Dental'),
      buildStatus(id: 's4', soldierId: 'Pte Chua', name: 'LD'),
    ];

    test('has four rows: officers, WOSEs, on status, on MA', () {
      final s = summaryOf(roster, statuses);
      expect(s.rows.map((r) => r.kind), ParadeReportKind.values);
      expect(s.rows.map((r) => (r.current, r.total)), [
        (2, 3),
        (1, 3),
        (3, null),
        (1, null),
      ]);
    });

    test('the group lists follow the tick-strip order, input order within', () {
      final s = summaryOf(roster, statuses);
      expect(soldiersOf(s.officersByState), [lt, maj, cpt]);
      expect(soldiersOf(s.wosesByState), [pte, cpl, sct]);
      expect(s.officersByState.map((e) => e.state), [
        ParadeState.inCamp,
        ParadeState.excuse,
        ParadeState.leave,
      ]);
      expect(s.wosesByState.map((e) => e.state), [
        ParadeState.excuse,
        ParadeState.medical,
        ParadeState.out,
      ]);
    });

    test('a row stands for the states its figure counts', () {
      final s = summaryOf(roster, statuses);
      final inCampStates = {ParadeState.inCamp, ParadeState.excuse};
      final officers = s.row(ParadeReportKind.officers);
      final woses = s.row(ParadeReportKind.woses);
      expect(officers.highlightedStates(ParadeGroup.officers), inCampStates);
      expect(officers.highlightedStates(ParadeGroup.woses), isEmpty);
      expect(woses.highlightedStates(ParadeGroup.woses), inCampStates);
      expect(woses.highlightedStates(ParadeGroup.officers), isEmpty);
      for (final group in ParadeGroup.values) {
        expect(s.row(ParadeReportKind.onStatus).highlightedStates(group),
            {ParadeState.excuse, ParadeState.leave});
        expect(s.row(ParadeReportKind.onMa).highlightedStates(group),
            {ParadeState.medical});
      }
    });

    test('a row names the status it lists, else the state', () {
      final both = summaryOf([
        cpl
      ], [
        buildStatus(soldierId: 'Cpl Tan', name: 'Ex RMJ'),
        buildStatus(
            id: 's2',
            soldierId: 'Cpl Tan',
            type: 'Medical Appointment',
            name: 'Dental'),
      ]);
      final entry = both.entries.single;
      expect(both.row(ParadeReportKind.onStatus).labelOf(entry), 'Ex RMJ');
      expect(both.row(ParadeReportKind.onMa).labelOf(entry), 'Dental');
      expect(both.row(ParadeReportKind.woses).labelOf(entry), 'Dental');

      final plain = summaryOf([cpl, sct]);
      expect(plain.row(ParadeReportKind.woses).labelOf(plain.entries.first),
          'In camp');
      expect(plain.row(ParadeReportKind.woses).labelOf(plain.entries.last),
          'Booked out');
    });

    test('rows compare by value and the empty report has empty rows', () {
      expect(
          summaryOf(roster, statuses).rows, summaryOf(roster, statuses).rows);
      final empty = summaryOf(const []);
      expect(
          empty.rows.every((r) => r.entries.isEmpty && r.current == 0), isTrue);
      expect(empty.total, 0);
    });
  });

  group('WatchStrengthSummary', () {
    test('combines soldiers and statuses; no status needed', () async {
      final watchSoldiers = _MockSoldiers();
      final statusRepo = _MockStatuses();
      when(() => watchSoldiers(const NoParams())).thenAnswer(
          (_) => Stream.value(Right<Failure, List<Soldier>>(soldiers)));
      when(() => statusRepo.watchAll()).thenAnswer(
          (_) => Stream.value(const Right<Failure, List<Status>>([])));
      WatchStrengthSummary build() => WatchStrengthSummary(
          WatchParadeRoster(watchSoldiers, statusRepo, FixedClock(today)));

      final first = await build()(const NoParams()).first;
      expect(first.getOrElse(() => throw 'x').total, 4);

      when(() => statusRepo.watchAll()).thenAnswer((_) => Stream.value(
          const Left<Failure, List<Status>>(ServerFailure('down'))));
      expect((await build()(const NoParams()).first).isLeft(), isTrue);
    });

    test('wraps the roster entries and passes a failure through', () async {
      final roster = _MockRoster();
      final entries = paradeRoster(soldiers, const [], today);
      when(() => roster(const NoParams())).thenAnswer(
          (_) => Stream.value(Right<Failure, List<ParadeEntry>>(entries)));
      expect(await WatchStrengthSummary(roster)(const NoParams()).first,
          Right<Failure, StrengthSummary>(StrengthSummary(entries: entries)));

      when(() => roster(const NoParams())).thenAnswer((_) => Stream.value(
          const Left<Failure, List<ParadeEntry>>(ServerFailure('down'))));
      expect(await WatchStrengthSummary(roster)(const NoParams()).first,
          const Left<Failure, StrengthSummary>(ServerFailure('down')));
    });
  });
}
