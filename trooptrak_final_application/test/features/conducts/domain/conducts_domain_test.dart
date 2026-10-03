import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/constants/conduct_types.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/conducts/domain/entities/conduct.dart';
import 'package:trooptrak_final_application/features/conducts/domain/repositories/conduct_repository.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/build_conduct_roster.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/conduct_usecases.dart';
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
  });
}
