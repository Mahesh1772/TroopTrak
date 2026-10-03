import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/entities/duty.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/repositories/duty_repository.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/services/duty_points.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/usecases/duty_usecases.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/repositories/soldier_repository.dart';
import 'package:trooptrak_final_application/features/statuses/domain/repositories/status_repository.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';

class _MockDuties extends Mock implements DutyRepository {}

class _MockSoldiers extends Mock implements SoldierRepository {}

class _MockStatuses extends Mock implements StatusRepository {}

void main() {
  group('DutyPoints.forDate (R7)', () {
    // 3 Jul 2023 is a Monday.
    for (final (offset, points, label) in [
      (0, 1.0, 'Weekday Duty 🫣'),
      (1, 1.0, 'Weekday Duty 🫣'),
      (2, 1.0, 'Weekday Duty 🫣'),
      (3, 1.0, 'Weekday Duty 🫣'),
      (4, 1.5, 'Weekday (Friday) Duty 😖'),
      (5, 2.5, 'Weekend (Saturday) Duty 😵‍💫'),
      (6, 2.0, 'Weekend (Sunday) Duty 🤧'),
    ]) {
      test('day +$offset → $points "$label"', () {
        final day = DutyPoints.forDate(DateTime(2023, 7, 3 + offset));
        expect(day.points, points);
        expect(day.dayType, label);
      });
    }

    test('no date → 0 and the prompt', () {
      expect(DutyPoints.forDate(null),
          (points: 0.0, dayType: 'Select a duty date! 😄'));
    });
  });

  group('DutyLedger', () {
    const a = {'A': 'CPL', 'B': 'PTE'};
    const b = {'B': 'PTE', 'C': 'LCP'};

    test('add and delete move every participant by the duty points', () {
      expect(DutyLedger.add(a, 2.5), {
        'A': const PointsChange(add: 2.5),
        'B': const PointsChange(add: 2.5)
      });
      expect(DutyLedger.delete(a, 1.5), {
        'A': const PointsChange(subtract: 1.5),
        'B': const PointsChange(subtract: 1.5)
      });
    });

    test('delete clamps at zero (R9)', () {
      expect(const PointsChange(subtract: 2.5).applyTo(1), 0);
      expect(const PointsChange(subtract: 1).applyTo(2.5), 1.5);
    });

    test('update reverses old points from old participants, then adds new (K6)',
        () {
      final changes = DutyLedger.update(
          before: a, beforePoints: 1, after: b, afterPoints: 2.5);
      expect(changes, {
        'A': const PointsChange(subtract: 1),
        'B': const PointsChange(subtract: 1, add: 2.5),
        'C': const PointsChange(add: 2.5),
      });
      expect(changes['A']!.applyTo(0.5), 0);
      expect(changes['B']!.applyTo(0.5), 2.5);
      expect(changes['C']!.applyTo(3), 5.5);
    });
  });

  group('duty use cases', () {
    late _MockDuties repo;

    setUpAll(() => registerFallbackValue(buildDuty()));

    setUp(() {
      repo = _MockDuties();
      when(() => repo.add(any(), any()))
          .thenAnswer((_) async => const Right(unit));
      when(() => repo.update(any(), any()))
          .thenAnswer((_) async => const Right(unit));
      when(() => repo.delete(any(), any()))
          .thenAnswer((_) async => const Right(unit));
    });

    test('add prices the duty from its date and credits participants',
        () async {
      final sunday =
          buildDuty(start: DateTime(2023, 7, 9, 8), points: 0, dayType: 'x');
      await AddDuty(repo)(sunday);
      final captured =
          verify(() => repo.add(captureAny(), captureAny())).captured;
      expect((captured[0] as Duty).points, 2.0);
      expect((captured[0] as Duty).dayType, 'Weekend (Sunday) Duty 🤧');
      expect(captured[1], {'Tan Ah Kow': const PointsChange(add: 2.0)});
    });

    test('more than 10 participants is refused (R10a)', () async {
      final crowded = buildDuty(participants: {
        for (var i = 0; i < 11; i++) 'S$i': 'PTE',
      });
      expect(await AddDuty(repo)(crowded),
          const Left<Failure, Unit>(ValidationFailure(tooManySlots)));
      verifyNever(() => repo.add(any(), any()));
    });

    test('update keeps the id and applies the K6 ledger', () async {
      final previous = buildDuty(points: 1.5);
      final updated = buildDuty(
          id: '',
          start: DateTime(2023, 7, 8, 8),
          participants: {'Lee Wei': '2LT'});
      await UpdateDuty(repo)(
          UpdateDutyParams(previous: previous, updated: updated));
      final captured =
          verify(() => repo.update(captureAny(), captureAny())).captured;
      expect((captured[0] as Duty).id, 'd1');
      expect((captured[0] as Duty).points, 2.5);
      expect(captured[1], {
        'Tan Ah Kow': const PointsChange(subtract: 1.5),
        'Lee Wei': const PointsChange(add: 2.5),
      });
    });

    test('delete debits the stored points', () async {
      await DeleteDuty(repo)(buildDuty());
      verify(() => repo.delete(
              buildDuty(), {'Tan Ah Kow': const PointsChange(subtract: 1.5)}))
          .called(1);
    });
  });

  test('GetDutyRoster marks leave and Ex Uniform/Ex Boots ineligible (R6)',
      () async {
    final soldiers = _MockSoldiers();
    final statuses = _MockStatuses();
    final all = [
      buildSoldier(name: 'Tan Ah Kow'),
      buildSoldier(name: 'Lee Wei'),
      buildSoldier(name: 'Lim Bah'),
      buildSoldier(name: 'Ong Kai'),
    ];
    when(() => soldiers.getAll()).thenAnswer((_) async => Right(all));
    when(() => statuses.getAll()).thenAnswer((_) async => Right([
          buildStatus(soldierId: 'Tan Ah Kow', name: 'Ex Boots'),
          buildStatus(soldierId: 'Lee Wei', type: 'Leave', name: 'OL'),
          buildStatus(soldierId: 'Lim Bah', name: 'Ex RMJ'),
        ]));
    final roster = (await GetDutyRoster(soldiers, statuses,
            FixedClock(DateTime(2023, 7, 5)))(const NoParams()))
        .getOrElse(() => throw 'x');
    expect(roster.soldiers, all);
    expect(roster.ineligible, {'Tan Ah Kow', 'Lee Wei'});
    expect(roster.canServe(all[2]), isTrue);

    when(() => soldiers.getAll())
        .thenAnswer((_) async => const Left(ServerFailure('down')));
    expect(
        (await GetDutyRoster(soldiers, statuses,
                FixedClock(DateTime(2023, 7, 5)))(const NoParams()))
            .isLeft(),
        isTrue);
  });
}
