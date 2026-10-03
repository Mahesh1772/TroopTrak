import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_soldiers_in_camp.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/entities/strength_summary.dart';
import 'package:trooptrak_final_application/features/dashboard/domain/usecases/watch_strength_summary.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/repositories/status_repository.dart';

import '../../helpers/builders.dart';
import '../../helpers/fake_clock.dart';

class _MockSoldiers extends Mock implements WatchSoldiersInCamp {}

class _MockStatuses extends Mock implements StatusRepository {}

void main() {
  final today = DateTime(2023, 7, 5, 9);
  final lt = buildSoldier(name: 'Lt Lee', rank: '2LT');
  final cpt = buildSoldier(name: 'Cpt Ong', rank: 'CPT', isInCamp: false);
  final cpl = buildSoldier(name: 'Cpl Tan', rank: 'CPL');
  final sct = buildSoldier(name: 'Sct Lim', rank: 'SCT', isInCamp: false);
  final odd = buildSoldier(name: 'Odd Rank', rank: 'XYZ');
  final soldiers = [lt, cpt, cpl, sct, odd];

  test('officers vs WOSEs (R4) with in-camp counts; unknown ranks in neither',
      () {
    final s = buildStrengthSummary(soldiers, const [], today);
    expect(s.officers, [lt, cpt]);
    expect(s.woses, [cpl, sct]);
    expect(s.officersInCamp, [lt]);
    expect(s.wosesInCamp, [cpl]);
    expect(s.total, 4);
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
    final s = buildStrengthSummary(soldiers, statuses, today);
    expect(s.onStatus, [cpl]);
    expect(s.onMa, [lt]);
  });

  test('a status starting today and ending today counts', () {
    final s = buildStrengthSummary(
        soldiers,
        [
          buildStatus(
              soldierId: 'Cpt Ong',
              start: DateTime(2023, 7, 5),
              end: DateTime(2023, 7, 5)),
        ],
        today);
    expect(s.onStatus, [cpt]);
  });

  test('WatchStrengthSummary combines soldiers and statuses; no status needed',
      () async {
    final watchSoldiers = _MockSoldiers();
    final statusRepo = _MockStatuses();
    when(() => watchSoldiers(const NoParams())).thenAnswer(
        (_) => Stream.value(Right<Failure, List<Soldier>>(soldiers)));
    when(() => statusRepo.watchAll()).thenAnswer(
        (_) => Stream.value(const Right<Failure, List<Status>>([])));
    final first = await WatchStrengthSummary(
            watchSoldiers, statusRepo, FixedClock(today))(const NoParams())
        .first;
    expect(first.getOrElse(() => throw 'x').total, 4);

    when(() => statusRepo.watchAll()).thenAnswer((_) =>
        Stream.value(const Left<Failure, List<Status>>(ServerFailure('down'))));
    expect(
        (await WatchStrengthSummary(watchSoldiers, statusRepo,
                    FixedClock(today))(const NoParams())
                .first)
            .isLeft(),
        isTrue);
  });
}
