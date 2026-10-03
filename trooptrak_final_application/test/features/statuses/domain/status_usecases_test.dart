import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/repositories/status_repository.dart';
import 'package:trooptrak_final_application/features/statuses/domain/usecases/status_usecases.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';

class _MockRepo extends Mock implements StatusRepository {}

void main() {
  late _MockRepo repo;

  setUpAll(() => registerFallbackValue(buildStatus()));
  setUp(() => repo = _MockRepo());

  test('watch use cases delegate to the repository', () async {
    final list = [buildStatus()];
    when(() => repo.watchForSoldier('Tan Ah Kow'))
        .thenAnswer((_) => Stream.value(Right(list)));
    when(() => repo.watchAll()).thenAnswer((_) => Stream.value(Right(list)));

    expect(await WatchSoldierStatuses(repo)('Tan Ah Kow').first,
        Right<Failure, List<Status>>(list));
    expect(await WatchAllStatuses(repo)(const NoParams()).first,
        Right<Failure, List<Status>>(list));
  });

  test('GetActiveStatuses keeps only statuses active on the clock day',
      () async {
    final active = buildStatus(id: 'a', end: DateTime(2023, 7, 5));
    final expired = buildStatus(id: 'e', end: DateTime(2023, 7, 4));
    when(() => repo.getAll()).thenAnswer((_) async => Right([active, expired]));

    final result = await GetActiveStatuses(
        repo, FixedClock(DateTime(2023, 7, 5, 18)))(const NoParams());
    expect(result.getOrElse(() => []), [active]);
  });

  test('GetActiveStatuses passes failures through', () async {
    when(() => repo.getAll())
        .thenAnswer((_) async => const Left(ServerFailure('x')));
    expect(
        await GetActiveStatuses(repo, FixedClock(DateTime(2023)))(
            const NoParams()),
        const Left<Failure, List<Status>>(ServerFailure('x')));
  });

  group('AddStatus', () {
    test('trims the name and saves', () async {
      when(() => repo.add(any())).thenAnswer((_) async => const Right(unit));
      await AddStatus(repo)(buildStatus(name: '  LD  '));
      expect(verify(() => repo.add(captureAny())).captured.single,
          buildStatus(name: 'LD'));
    });

    test('rejects an unknown type or an empty name', () async {
      expect((await AddStatus(repo)(buildStatus(type: 'Holiday'))).isLeft(),
          isTrue);
      expect((await AddStatus(repo)(buildStatus(name: ' '))).isLeft(), isTrue);
      verifyNever(() => repo.add(any()));
    });

    test('K18: rejects an end before the start; same day is fine', () async {
      when(() => repo.add(any())).thenAnswer((_) async => const Right(unit));
      expect(
          await AddStatus(repo)(buildStatus(
              start: DateTime(2023, 7, 5), end: DateTime(2023, 7, 4, 23))),
          const Left<Failure, Unit>(ValidationFailure(endBeforeStart)));
      expect(
          await AddStatus(repo)(buildStatus(
              start: DateTime(2023, 7, 5, 9), end: DateTime(2023, 7, 5))),
          const Right<Failure, Unit>(unit));
    });
  });

  group('UpdateStatus', () {
    test('passes previous and trimmed updated status', () async {
      when(() => repo.update(any(), any()))
          .thenAnswer((_) async => const Right(unit));
      final previous = buildStatus();
      await UpdateStatus(repo)(UpdateStatusParams(
          previous: previous,
          updated: buildStatus(type: 'Leave', name: ' OL ')));
      verify(() =>
              repo.update(previous, buildStatus(type: 'Leave', name: 'OL')))
          .called(1);
    });

    test('rejects an invalid update', () async {
      final result = await UpdateStatus(repo)(UpdateStatusParams(
          previous: buildStatus(), updated: buildStatus(name: '')));
      expect(result.isLeft(), isTrue);
      verifyNever(() => repo.update(any(), any()));
    });
  });

  test('DeleteStatus delegates', () async {
    when(() => repo.delete(any())).thenAnswer((_) async => const Right(unit));
    expect(await DeleteStatus(repo)(buildStatus()),
        const Right<Failure, Unit>(unit));
  });
}
