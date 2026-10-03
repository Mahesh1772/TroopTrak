import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/exceptions.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/statuses/data/datasources/status_remote_data_source.dart';
import 'package:trooptrak_final_application/features/statuses/data/models/status_model.dart';
import 'package:trooptrak_final_application/features/statuses/data/repositories/status_repository_impl.dart';
import 'package:trooptrak_final_application/features/statuses/domain/entities/status.dart';
import 'package:trooptrak_final_application/features/statuses/domain/usecases/status_usecases.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';
import '../../../helpers/firestore_seed.dart';

class _MockRemote extends Mock implements StatusRemoteDataSource {}

void main() {
  late FakeFirebaseFirestore db;
  late StatusRepositoryImpl repo;

  setUp(() async {
    db = await seedFirestore(soldiers: [
      SeededSoldier(soldierDoc()),
      SeededSoldier(soldierDoc(name: 'Lee Wei', rank: '2LT')),
    ]);
    repo = StatusRepositoryImpl(StatusRemoteDataSource(db));
  });

  Future<List<Status>> statusesOf(String soldier) async =>
      (await repo.watchForSoldier(soldier).first).getOrElse(() => []);

  Future<Map<String, Map<String, dynamic>>> attendanceOf(String soldier) async {
    final snap = await db
        .collection('Users')
        .doc(soldier)
        .collection('Attendance')
        .get();
    return {for (final d in snap.docs) d.id: d.data()};
  }

  group('StatusModel', () {
    test('round-trips with exact field names and d MMM yyyy dates', () {
      final map = StatusModel.toMap(buildStatus(
          type: 'Leave',
          start: DateTime(2023, 7, 3),
          end: DateTime(2023, 7, 5)));
      expect(map, {
        'statusName': 'Ex RMJ',
        'statusType': 'Leave',
        'startDate': '3 Jul 2023',
        'endDate': '5 Jul 2023',
        'start_id': '2023-07-03 00:30:00',
        'end_id': '2023-07-05 22:00:00',
      });
      final back = StatusModel.fromMap('Tan Ah Kow', 's1', map);
      expect(back.start, DateTime(2023, 7, 3));
      expect(back.end, DateTime(2023, 7, 5));
      expect(back.startAttendanceId, '2023-07-03 00:30:00');
    });

    test('unparseable dates read as long expired; missing ids are null', () {
      final s = StatusModel.fromMap(
          'a', 'b', {'statusType': 'Excuse', 'endDate': '??'});
      expect(s.end, DateTime(1970));
      expect(s.isActiveOn(DateTime(2023)), isFalse);
      expect(s.startAttendanceId, isNull);
    });
  });

  test('add Excuse stores the status and no attendance', () async {
    await repo.add(buildStatus(name: 'LD'));
    final saved = (await statusesOf('Tan Ah Kow')).single;
    expect(saved.name, 'LD');
    expect(saved.startAttendanceId, '2023-07-01 00:30:00');
    expect(await attendanceOf('Tan Ah Kow'), isEmpty);
  });

  test('add Leave also books out at start 00:30 and in at end 22:00 (R21)',
      () async {
    await repo.add(buildStatus(
        type: 'Leave',
        name: 'OL',
        start: DateTime(2023, 7, 3),
        end: DateTime(2023, 7, 5)));
    expect(await attendanceOf('Tan Ah Kow'), {
      '2023-07-03 00:30:00': {
        'isInsideCamp': false,
        'date&time': 'Mon 3 Jul 2023 00:30:00'
      },
      '2023-07-05 22:00:00': {
        'isInsideCamp': true,
        'date&time': 'Wed 5 Jul 2023 22:00:00'
      },
    });
  });

  test('update moves linked records and refreshes start_id/end_id (K15)',
      () async {
    await repo.add(buildStatus(
        type: 'Leave', start: DateTime(2023, 7, 3), end: DateTime(2023, 7, 5)));
    final previous = (await statusesOf('Tan Ah Kow')).single;

    await repo.update(
        previous,
        previous.copyWith(
            start: DateTime(2023, 7, 10), end: DateTime(2023, 7, 12)));

    expect((await attendanceOf('Tan Ah Kow')).keys,
        unorderedEquals(['2023-07-10 00:30:00', '2023-07-12 22:00:00']));
    final updated = (await statusesOf('Tan Ah Kow')).single;
    expect(updated.startAttendanceId, '2023-07-10 00:30:00');
    expect(updated.endAttendanceId, '2023-07-12 22:00:00');
    expect(updated.id, previous.id);
  });

  test('update with unchanged dates keeps the linked records', () async {
    await repo.add(buildStatus(type: 'Medical Appointment'));
    final previous = (await statusesOf('Tan Ah Kow')).single;
    await repo.update(previous, previous.copyWith(name: 'Dental'));
    expect((await attendanceOf('Tan Ah Kow')).length, 2);
    expect((await statusesOf('Tan Ah Kow')).single.name, 'Dental');
  });

  test('changing Leave to Excuse removes linked records; back again adds them',
      () async {
    await repo.add(buildStatus(type: 'Leave'));
    final leave = (await statusesOf('Tan Ah Kow')).single;

    await repo.update(leave, leave.copyWith(type: 'Excuse'));
    expect(await attendanceOf('Tan Ah Kow'), isEmpty);

    final excuse = (await statusesOf('Tan Ah Kow')).single;
    await repo.update(excuse, excuse.copyWith(type: 'Leave'));
    expect((await attendanceOf('Tan Ah Kow')).length, 2);
  });

  test('delete removes the status and its linked records only', () async {
    await db
        .collection('Users')
        .doc('Tan Ah Kow')
        .collection('Attendance')
        .doc('2023-06-30 08:00:00')
        .set(attendanceDoc());
    await repo.add(buildStatus(type: 'Leave'));
    final leave = (await statusesOf('Tan Ah Kow')).single;

    await repo.delete(leave);

    expect(await statusesOf('Tan Ah Kow'), isEmpty);
    expect((await attendanceOf('Tan Ah Kow')).keys, ['2023-06-30 08:00:00']);
  });

  test('watchAll and getAll return every soldier\'s statuses with ids',
      () async {
    await repo.add(buildStatus(name: 'LD'));
    await repo
        .add(buildStatus(soldierId: 'Lee Wei', type: 'Leave', name: 'OL'));

    final all = (await repo.getAll()).getOrElse(() => []);
    expect({for (final s in all) s.soldierId: s.name},
        {'Tan Ah Kow': 'LD', 'Lee Wei': 'OL'});
    final watched = (await repo.watchAll().first).getOrElse(() => []);
    expect(watched.length, 2);
  });

  test('GetActiveStatuses filters by the fixed clock over real data', () async {
    await repo.add(buildStatus(name: 'LD', end: DateTime(2023, 7, 5)));
    await repo.add(buildStatus(name: 'Ex RMJ', end: DateTime(2023, 7, 4)));
    final active = await GetActiveStatuses(
        repo, FixedClock(DateTime(2023, 7, 5, 23)))(const NoParams());
    expect(active.getOrElse(() => []).map((s) => s.name), ['LD']);
  });

  test('update of a missing status is a Left', () async {
    expect(
        (await repo.update(buildStatus(id: 'ghost'), buildStatus())).isLeft(),
        isTrue);
  });

  test('errors become Left', () async {
    final remote = _MockRemote();
    when(() => remote.getAll()).thenThrow(const ServerException('down'));
    when(() => remote.watchAll())
        .thenAnswer((_) => Stream.error(const ServerException('down')));
    final failing = StatusRepositoryImpl(remote);
    expect(await failing.getAll(),
        const Left<Failure, List<Status>>(ServerFailure('down')));
    expect(await failing.watchAll().first,
        const Left<Failure, List<Status>>(ServerFailure('down')));
  });
}
