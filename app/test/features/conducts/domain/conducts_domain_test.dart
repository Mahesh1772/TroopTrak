import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/constants/conduct_types.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/conducts/domain/entities/conduct.dart';
import 'package:trooptrak_final_application/features/conducts/domain/repositories/conduct_repository.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/build_conduct_roster.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/conduct_usecases.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/watch_conduct_breakdown.dart';
import 'package:trooptrak_final_application/features/conducts/domain/validators/conduct_date_limits.dart';
import 'package:trooptrak_final_application/features/conducts/domain/validators/conduct_validators.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/repositories/soldier_repository.dart';
import 'package:trooptrak_final_application/features/statuses/domain/repositories/status_repository.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';

class _MockConducts extends Mock implements ConductRepository {}

class _MockSoldiers extends Mock implements SoldierRepository {}

class _MockStatuses extends Mock implements StatusRepository {}

void main() {
  final today = DateTime(2023, 7, 5, 9);
  final tan = buildSoldier(name: 'Tan Ah Kow');
  final lee = buildSoldier(name: 'Lee Wei');
  final lim = buildSoldier(name: 'Lim Bah');
  final ong = buildSoldier(name: 'Ong Kai');
  final soldiers = [tan, lee, lim, ong];

  final statuses = [
    buildStatus(soldierId: 'Tan Ah Kow', type: 'Excuse', name: 'Ex RMJ'),
    buildStatus(soldierId: 'Lee Wei', type: 'Leave', name: 'OL'),
    buildStatus(
        soldierId: 'Lim Bah', type: 'Medical Appointment', name: 'Dental'),
    buildStatus(
        soldierId: 'Ong Kai',
        type: 'Excuse',
        name: 'LD',
        end: DateTime(2023, 7, 4)),
  ];

  group('ConductValidators', () {
    test('type needs a choice', () {
      expect(ConductValidators.type(null), 'Bruh select!');
      expect(ConductValidators.type(ConductTypes.run), isNull);
    });

    test('name needs something other than spaces', () {
      const message = 'Oi can add conduct please?';
      expect(ConductValidators.name(null), message);
      expect(ConductValidators.name('   '), message);
      expect(ConductValidators.name(' 5km '), isNull);
    });

    test('date and both times need a pick', () {
      expect(ConductValidators.date(null), 'Select a date');
      expect(ConductValidators.date(today), isNull);
      expect(ConductValidators.startTime(null), 'Select a start time');
      expect(ConductValidators.startTime(today), isNull);
      expect(ConductValidators.endTime(null), 'Select an end time');
      expect(ConductValidators.endTime(today), isNull);
    });
  });

  group('ConductDateLimits', () {
    test('the date picker runs from 2022 to a year after today', () {
      expect(ConductDateLimits.earliest, DateTime(2022));
      expect(ConductDateLimits.latest(DateTime(2023, 7, 5, 9)),
          DateTime(2024, 7, 5));
    });
  });

  group('rosterFor (R5)', () {
    test('Run excludes the RMJ excuse and the leave, never the MA', () {
      expect(
        rosterFor(ConductTypes.run, soldiers, statuses, today),
        const ConductRoster(
          participants: ['Lim Bah', 'Ong Kai'],
          reasons: {'Tan Ah Kow': 'Ex RMJ', 'Lee Wei': 'OL'},
        ),
      );
    });

    test('a type that does not list the excuse keeps that soldier', () {
      final roster =
          rosterFor(ConductTypes.outfield, soldiers, statuses, today);
      expect(roster.participants, ['Tan Ah Kow', 'Lim Bah', 'Ong Kai']);
      expect(roster.reasons, {'Lee Wei': 'OL'});
    });

    test('an unknown type excludes leave only', () {
      expect(rosterFor('Swim', soldiers, statuses, today).reasons,
          {'Lee Wei': 'OL'});
    });

    for (final type in ConductTypes.all) {
      test('$type always excludes leave and never MA', () {
        final roster = rosterFor(type, soldiers, statuses, today);
        expect(roster.reasons['Lee Wei'], 'OL');
        expect(roster.participants, contains('Lim Bah'));
        expect(roster.participants, contains('Ong Kai'));
      });
    }
  });

  group('BuildConductRoster', () {
    late _MockSoldiers soldierRepo;
    late _MockStatuses statusRepo;

    setUp(() {
      soldierRepo = _MockSoldiers();
      statusRepo = _MockStatuses();
    });

    test('combines all soldiers and all statuses on the clock day', () async {
      when(() => soldierRepo.getAll()).thenAnswer((_) async => Right(soldiers));
      when(() => statusRepo.getAll()).thenAnswer((_) async => Right(statuses));
      final roster = await BuildConductRoster(
          soldierRepo, statusRepo, FixedClock(today))(ConductTypes.ippt);
      expect(roster.getOrElse(() => throw 'x').reasons,
          {'Lee Wei': 'OL', 'Tan Ah Kow': 'Ex RMJ'});
    });

    test('failures pass through', () async {
      when(() => soldierRepo.getAll())
          .thenAnswer((_) async => const Left(ServerFailure('down')));
      expect(
          await BuildConductRoster(soldierRepo, statusRepo, FixedClock(today))(
              ConductTypes.run),
          const Left<Failure, ConductRoster>(ServerFailure('down')));
      verifyNever(() => statusRepo.getAll());
    });
  });

  group('Conduct', () {
    test('reason falls back to "Removed from conduct"', () {
      final c = buildConduct(soldierReason: {'Lee Wei': 'OL'});
      expect(c.reasonFor('Lee Wei'), 'OL');
      expect(c.reasonFor('Lim Bah'), Conduct.removedReason);
      expect(c.includes('Tan Ah Kow'), isTrue);
      expect(c.day, DateTime(2023, 7, 5));
    });
  });

  group('add / update / delete use cases', () {
    late _MockConducts repo;
    setUpAll(() => registerFallbackValue(buildConduct()));
    setUp(() {
      repo = _MockConducts();
      when(() => repo.add(any())).thenAnswer((_) async => const Right(unit));
      when(() => repo.update(any())).thenAnswer((_) async => const Right(unit));
      when(() => repo.delete(any())).thenAnswer((_) async => const Right(unit));
    });

    test('trim the name and save', () async {
      await AddConduct(repo)(buildConduct(name: '  Run  '));
      verify(() => repo.add(buildConduct(name: 'Run'))).called(1);
      await UpdateConduct(repo)(buildConduct(name: ' IPPT '));
      verify(() => repo.update(buildConduct(name: 'IPPT'))).called(1);
      await DeleteConduct(repo)('c1');
      verify(() => repo.delete('c1')).called(1);
    });

    test('reject an unknown type or empty name with the source texts',
        () async {
      expect(await AddConduct(repo)(buildConduct(type: 'Select conduct...')),
          const Left<Failure, Unit>(ValidationFailure('Bruh select!')));
      expect(
          await UpdateConduct(repo)(buildConduct(name: ' ')),
          const Left<Failure, Unit>(
              ValidationFailure('Oi can add conduct please?')));
      verifyNever(() => repo.add(any()));
    });

    test('refuse an end time before the start; equal times are fine', () async {
      expect(
          await AddConduct(repo)(buildConduct(
              start: DateTime(2023, 7, 5, 9), end: DateTime(2023, 7, 5, 8))),
          const Left<Failure, Unit>(ValidationFailure(endBeforeStartTime)));
      expect(
          await AddConduct(repo)(buildConduct(
              start: DateTime(2023, 7, 5, 9), end: DateTime(2023, 7, 5, 9))),
          const Right<Failure, Unit>(unit));
    });
  });

  test('WatchConductsOnDay asks the repository for that day (R13)', () async {
    final repo = _MockConducts();
    final day = DateTime(2023, 7, 5);
    final list = [buildConduct()];
    when(() => repo.watchOnDay(day))
        .thenAnswer((_) => Stream.value(Right(list)));
    expect(await WatchConductsOnDay(repo)(day).first,
        Right<Failure, List<Conduct>>(list));
  });

  test('ConductBreakdown compares by value', () {
    final run = buildConduct();
    final soldier = buildSoldier();
    ConductBreakdown of(List<String> names) => ConductBreakdown(
        conduct: run,
        roster: [for (final n in names) soldier.copyWith(name: n)]);
    expect(of(['A']), of(['A']));
    expect(of(['A']), isNot(of(['B'])));
  });

  group('ConductBreakdown', () {
    final staff = buildSoldier(
        name: 'Tan Ah Kow', rank: 'CPL', appointment: 'Section IC');
    final out = buildSoldier(name: 'Lee Wei', rank: '2LT');
    final removed = buildSoldier(name: 'Lim Bah', rank: 'PTE');
    final run = buildConduct(
        participants: ['Tan Ah Kow'], soldierReason: {'Lee Wei': 'OL'});
    final breakdown = breakdownOf(run, [out, staff, removed]);

    test('members picks the group and keeps roster order', () {
      expect(breakdown.members(ConductGroup.participants), [staff]);
      expect(breakdown.members(ConductGroup.nonParticipants), [out, removed]);
    });

    test('noteFor is the appointment, the status reason or the fallback', () {
      expect(breakdown.noteFor(staff), 'Section IC');
      expect(breakdown.noteFor(out), 'OL');
      expect(breakdown.noteFor(removed), Conduct.removedReason);
    });

    test('ticks run over the whole roster in order', () {
      final ticks = breakdown.ticks;
      expect(ticks.ticks.map((t) => t.soldier), [out, staff, removed]);
      expect(ticks.ticks.map((t) => t.tookPart), [false, true, false]);
      expect(ticks.participating, 1);
      expect(ticks.total, 3);
    });

    test('search narrows the roster, so ticks and groups follow it', () {
      final found = breakdown.search('LEE');
      expect(found.roster, [out]);
      expect(found.members(ConductGroup.participants), isEmpty);
      expect(found.members(ConductGroup.nonParticipants), [out]);
      expect(breakdown.search('').roster, breakdown.roster);
    });

    test('isEmpty is true only for an empty roster', () {
      expect(breakdown.isEmpty, isFalse);
      expect(breakdown.search('zzz').isEmpty, isTrue);
      expect(breakdownOf(run, const []).isEmpty, isTrue);
    });
  });
}
