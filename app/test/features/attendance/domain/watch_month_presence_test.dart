import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/attendance/domain/entities/attendance_record.dart';
import 'package:trooptrak_final_application/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_month_presence.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/repositories/status_repository.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_state.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';

class _MockAttendance extends Mock implements AttendanceRepository {}

class _MockStatuses extends Mock implements StatusRepository {}

void main() {
  final tan = buildSoldier(name: 'Tan');
  final now = DateTime(2026, 10, 8, 9, 30);

  late _MockAttendance attendance;
  late _MockStatuses statuses;
  late StreamController<Either<Failure, List<AttendanceRecord>>> recordStream;
  late StreamController<Either<Failure, List<Status>>> statusStream;

  setUp(() {
    attendance = _MockAttendance();
    statuses = _MockStatuses();
    recordStream = StreamController.broadcast();
    statusStream = StreamController.broadcast();
    when(() => attendance.watchForSoldier('Tan'))
        .thenAnswer((_) => recordStream.stream);
    when(() => statuses.watchForSoldier('Tan'))
        .thenAnswer((_) => statusStream.stream);
  });

  tearDown(() async {
    await recordStream.close();
    await statusStream.close();
  });

  Stream<Either<Failure, MonthReport>> watch([DateTime? at]) =>
      WatchMonthPresence(attendance, statuses, FixedClock(at ?? now))(tan);

  test('reports the clock\'s month from the soldier\'s own records', () async {
    final first = watch().first;
    recordStream.add(Right([
      buildAttendance(
          soldierId: 'Tan',
          isInsideCamp: false,
          timestamp: DateTime(2026, 10, 2, 17)),
      buildAttendance(soldierId: 'Tan', timestamp: DateTime(2026, 10, 4, 21)),
    ]));
    statusStream.add(const Right([]));

    final report = (await first).getOrElse(() => throw 'no report');
    expect(report.month, DateTime(2026, 10));
    expect(report.today, now);
    expect(report.presence.days.length, 31);
    expect(report.presence.days[0], ParadeState.inCamp);
    expect(report.presence.days[2], ParadeState.out);
    expect(report.presence.days[4], ParadeState.inCamp);
    expect(report.presence.days[8], isNull);
    expect(report.presence.elapsed, 8);
  });

  test('a leave on a past day overrides the booked-in flag', () async {
    final first = watch().first;
    recordStream.add(const Right([]));
    statusStream.add(Right([
      buildStatus(
        soldierId: 'Tan',
        type: 'Leave',
        start: DateTime(2026, 10, 3),
        end: DateTime(2026, 10, 4),
      ),
    ]));

    final days = (await first).getOrElse(() => throw 'no report').presence.days;
    expect(days[1], ParadeState.inCamp);
    expect(days[2], ParadeState.leave);
    expect(days[3], ParadeState.leave);
    expect(days[4], ParadeState.inCamp);
  });

  test('re-emits when either stream changes', () async {
    final emitted = <int>[];
    final sub = watch().listen(
        (e) => emitted.add(e.getOrElse(() => throw 'x').presence.inCampDays));
    recordStream.add(const Right([]));
    statusStream.add(const Right([]));
    await Future<void>.delayed(Duration.zero);
    statusStream.add(Right([
      buildStatus(
        soldierId: 'Tan',
        type: 'Leave',
        start: DateTime(2026, 10, 3),
        end: DateTime(2026, 10, 4),
      ),
    ]));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(emitted, [8, 6]);
  });

  test('a records failure is passed through', () async {
    final first = watch().first;
    recordStream.add(const Left(ServerFailure('records down')));
    statusStream.add(const Right([]));

    expect(await first,
        const Left<Failure, MonthReport>(ServerFailure('records down')));
  });

  test('a statuses failure is passed through', () async {
    final first = watch().first;
    recordStream.add(const Right([]));
    statusStream.add(const Left(ServerFailure('statuses down')));

    expect(await first,
        const Left<Failure, MonthReport>(ServerFailure('statuses down')));
  });
}
