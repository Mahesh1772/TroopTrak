import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/attendance/domain/entities/attendance_record.dart';
import 'package:trooptrak_final_application/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/attendance_usecases.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';

class _MockRepo extends Mock implements AttendanceRepository {}

void main() {
  final now = DateTime(2023, 7, 5, 9, 30, 20);
  final old = buildAttendance(timestamp: DateTime(2023, 7, 4, 8));
  final recent = buildAttendance(
      isInsideCamp: false, timestamp: DateTime(2023, 7, 5, 9, 30, 59));
  final future = buildAttendance(timestamp: DateTime(2023, 7, 5, 9, 31));

  group('visibleAttendance (R11)', () {
    test('sorts newest first and hides records after the current minute', () {
      expect(visibleAttendance([old, future, recent], now), [recent, old]);
    });

    test('empty input stays empty', () {
      expect(visibleAttendance(const [], now), isEmpty);
    });
  });

  group('effectiveInCamp (R21)', () {
    test('latest visible record decides', () {
      expect(
          effectiveInCamp([old, recent, future], now, fallback: true), isFalse);
      expect(effectiveInCamp([old], now, fallback: false), isTrue);
    });

    test('a future leave book-out does not count yet', () {
      final bookOut = buildAttendance(
          isInsideCamp: false, timestamp: DateTime(2023, 7, 6, 0, 30));
      expect(effectiveInCamp([old, bookOut], now, fallback: true), isTrue);
      expect(
          effectiveInCamp([old, bookOut], DateTime(2023, 7, 6, 0, 30),
              fallback: true),
          isFalse);
    });

    test('falls back to the stored value without visible records', () {
      expect(effectiveInCamp([future], now, fallback: false), isFalse);
      expect(effectiveInCamp(const [], now, fallback: true), isTrue);
    });
  });

  test('copyWith keeps the id and soldier', () {
    final moved = old.copyWith(timestamp: DateTime(2023, 1, 1));
    expect(moved.id, old.id);
    expect(moved.soldierId, old.soldierId);
    expect(moved.timestamp, DateTime(2023, 1, 1));
  });

  group('use cases', () {
    late _MockRepo repo;
    final clock = FixedClock(now);

    setUpAll(() => registerFallbackValue(old));
    setUp(() => repo = _MockRepo());

    test('WatchAttendance applies R11 with the clock', () async {
      when(() => repo.watchForSoldier('Tan Ah Kow'))
          .thenAnswer((_) => Stream.value(Right([old, future, recent])));
      final result = await WatchAttendance(repo, clock)('Tan Ah Kow').first;
      expect(result.getOrElse(() => []), [recent, old]);
    });

    test('WatchAttendance passes failures through', () async {
      when(() => repo.watchForSoldier(any()))
          .thenAnswer((_) => Stream.value(const Left(ServerFailure('x'))));
      expect(await WatchAttendance(repo, clock)('a').first,
          const Left<Failure, List<AttendanceRecord>>(ServerFailure('x')));
    });

    test('WatchAllAttendance delegates', () async {
      when(() => repo.watchAll()).thenAnswer((_) => Stream.value(Right([old])));
      expect(
          (await WatchAllAttendance(repo)(const NoParams()).first)
              .getOrElse(() => []),
          [old]);
    });

    test('BookInOut books at the clock time (R10)', () async {
      when(() => repo.bookInOut(any(), any(), any()))
          .thenAnswer((_) async => const Right(unit));
      await BookInOut(repo, clock)(
          const BookInOutParams('Tan Ah Kow', isInsideCamp: false));
      verify(() => repo.bookInOut('Tan Ah Kow', false, now)).called(1);
    });

    test('UpdateAttendance and DeleteAttendance delegate', () async {
      when(() => repo.update(any())).thenAnswer((_) async => const Right(unit));
      when(() => repo.delete(any())).thenAnswer((_) async => const Right(unit));
      expect(
          await UpdateAttendance(repo)(old), const Right<Failure, Unit>(unit));
      expect(
          await DeleteAttendance(repo)(old), const Right<Failure, Unit>(unit));
      verify(() => repo.update(old)).called(1);
      verify(() => repo.delete(old)).called(1);
    });

    test('BookInOutParams and AttendanceRecord compare by value', () {
      expect(const BookInOutParams('a', isInsideCamp: true),
          const BookInOutParams('a', isInsideCamp: true));
      expect(buildAttendance(id: 'r1'), buildAttendance(id: 'r1'));
      expect(buildAttendance(id: 'r1'), isNot(buildAttendance(id: 'r2')));
    });
  });
}
