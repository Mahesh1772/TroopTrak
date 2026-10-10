import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/attendance/domain/entities/attendance_record.dart';
import 'package:trooptrak_final_application/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_soldiers_in_camp.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/repositories/soldier_repository.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';

class _MockSoldiers extends Mock implements SoldierRepository {}

class _MockAttendance extends Mock implements AttendanceRepository {}

void main() {
  final now = DateTime(2023, 7, 5, 9);
  final tan = buildSoldier(name: 'Tan', isInCamp: true);
  final lee = buildSoldier(name: 'Lee', isInCamp: false);
  final lim = buildSoldier(name: 'Lim', isInCamp: true);

  final records = [
    buildAttendance(
        soldierId: 'Tan', isInsideCamp: true, timestamp: DateTime(2023, 7, 4)),
    buildAttendance(
        soldierId: 'Tan',
        isInsideCamp: false,
        timestamp: DateTime(2023, 7, 5, 8)),
    buildAttendance(
        soldierId: 'Lee',
        isInsideCamp: true,
        timestamp: DateTime(2023, 7, 5, 8, 30)),
    buildAttendance(
        soldierId: 'Lim',
        isInsideCamp: false,
        timestamp: DateTime(2023, 7, 6, 0, 30)),
  ];

  test('latest visible record wins; future-only or none falls back (R21)', () {
    final result = withEffectivePresence([tan, lee, lim], records, now);
    expect({for (final s in result) s.id: s.isInCamp},
        {'Tan': false, 'Lee': true, 'Lim': true});
    expect(result.first.copyWith(isInCamp: true), tan);
  });

  group('WatchSoldiersInCamp', () {
    late _MockSoldiers soldiers;
    late _MockAttendance attendance;
    late StreamController<Either<Failure, List<Soldier>>> soldierStream;
    late StreamController<Either<Failure, List<AttendanceRecord>>> recordStream;

    setUp(() {
      soldiers = _MockSoldiers();
      attendance = _MockAttendance();
      soldierStream = StreamController.broadcast();
      recordStream = StreamController.broadcast();
      when(() => soldiers.watchAll()).thenAnswer((_) => soldierStream.stream);
      when(() => attendance.watchAll()).thenAnswer((_) => recordStream.stream);
    });

    tearDown(() async {
      await soldierStream.close();
      await recordStream.close();
    });

    test('combines both streams and re-emits on either change', () async {
      final emitted = <Either<Failure, List<Soldier>>>[];
      final sub = WatchSoldiersInCamp(soldiers, attendance, FixedClock(now))(
              const NoParams())
          .listen(emitted.add);
      soldierStream.add(Right([tan]));
      recordStream.add(const Right([]));
      await Future<void>.delayed(Duration.zero);
      recordStream.add(Right(records));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(
          emitted.map((e) => e.getOrElse(() => [])[0].isInCamp), [true, false]);
    });

    test('a failure on either side is a Left', () async {
      final first = WatchSoldiersInCamp(soldiers, attendance, FixedClock(now))(
              const NoParams())
          .first;
      soldierStream.add(Right([tan]));
      recordStream.add(const Left(ServerFailure('down')));
      expect(await first,
          const Left<Failure, List<Soldier>>(ServerFailure('down')));
    });
  });
}
