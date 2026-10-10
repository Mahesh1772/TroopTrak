import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/repositories/soldier_repository.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/usecases/soldier_usecases.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';

class _MockRepo extends Mock implements SoldierRepository {}

void main() {
  late _MockRepo repo;
  final clock = FixedClock(DateTime(2023, 7, 5, 9, 30));

  setUpAll(() => registerFallbackValue(buildSoldier()));
  setUp(() => repo = _MockRepo());

  test('WatchSoldiers and WatchSoldier delegate to the repository', () async {
    final list = [buildSoldier()];
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value(Right(list)));
    when(() => repo.watchById('Tan Ah Kow'))
        .thenAnswer((_) => Stream.value(Right(list.first)));

    expect(await WatchSoldiers(repo)(const NoParams()).first,
        Right<Failure, List<Soldier>>(list));
    expect(await WatchSoldier(repo)('Tan Ah Kow').first,
        Right<Failure, Soldier>(list.first));
  });

  group('AddSoldier', () {
    test('uses the trimmed name as id, starts in camp with zero points',
        () async {
      when(() => repo.exists('Tan Ah Kow'))
          .thenAnswer((_) async => const Right(false));
      when(() => repo.add(any(), createdAt: any(named: 'createdAt')))
          .thenAnswer((_) async => const Right(unit));

      final result = await AddSoldier(repo, clock)(
        buildSoldier(name: '  Tan Ah Kow ', id: '', isInCamp: false, points: 9),
      );

      expect(result, const Right<Failure, Unit>(unit));
      final captured = verify(() =>
              repo.add(captureAny(), createdAt: DateTime(2023, 7, 5, 9, 30)))
          .captured
          .single as Soldier;
      expect(captured.id, 'Tan Ah Kow');
      expect(captured.name, 'Tan Ah Kow');
      expect(captured.isInCamp, isTrue);
      expect(captured.points, 0);
    });

    test('refuses an existing name (K13)', () async {
      when(() => repo.exists('Tan Ah Kow'))
          .thenAnswer((_) async => const Right(true));

      final result = await AddSoldier(repo, clock)(buildSoldier());

      expect(
          result,
          const Left<Failure, Unit>(
              ValidationFailure('A soldier named Tan Ah Kow already exists.')));
      verifyNever(() => repo.add(any(), createdAt: any(named: 'createdAt')));
    });

    test('rejects a blank name without touching the repository', () async {
      final result = await AddSoldier(repo, clock)(buildSoldier(name: '   '));
      expect(result.isLeft(), isTrue);
      verifyZeroInteractions(repo);
    });

    test('propagates a failure from the existence check', () async {
      when(() => repo.exists(any()))
          .thenAnswer((_) async => const Left(ServerFailure('down')));
      expect(await AddSoldier(repo, clock)(buildSoldier()),
          const Left<Failure, Unit>(ServerFailure('down')));
    });
  });

  test('UpdateSoldier trims the name and keeps the id', () async {
    when(() => repo.update(any())).thenAnswer((_) async => const Right(unit));
    await UpdateSoldier(repo)(buildSoldier(name: ' New Name ', id: 'Old Name'));
    final captured =
        verify(() => repo.update(captureAny())).captured.single as Soldier;
    expect(captured.name, 'New Name');
    expect(captured.id, 'Old Name');
  });

  test('UpdateSoldier rejects a blank name', () async {
    expect(
        (await UpdateSoldier(repo)(buildSoldier(name: ' '))).isLeft(), isTrue);
    verifyNever(() => repo.update(any()));
  });

  test('DeleteSoldier delegates the cascade delete', () async {
    when(() => repo.delete('Tan Ah Kow'))
        .thenAnswer((_) async => const Right(unit));
    expect(await DeleteSoldier(repo)('Tan Ah Kow'),
        const Right<Failure, Unit>(unit));
  });
}
