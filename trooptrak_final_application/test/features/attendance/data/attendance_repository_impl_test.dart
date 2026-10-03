import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/exceptions.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:trooptrak_final_application/features/attendance/data/models/attendance_model.dart';
import 'package:trooptrak_final_application/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:trooptrak_final_application/features/attendance/domain/entities/attendance_record.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/firestore_seed.dart';

class _MockRemote extends Mock implements AttendanceRemoteDataSource {}

void main() {
  late FakeFirebaseFirestore db;
  late AttendanceRepositoryImpl repo;

  setUp(() async {
    db = await seedFirestore(soldiers: [
      SeededSoldier(soldierDoc(), attendance: {
        '2023-07-04 08:00:00':
            attendanceDoc(dateTime: 'Tue 4 Jul 2023 08:00:00'),
      }),
      SeededSoldier(soldierDoc(name: 'Lee Wei', rank: '2LT')),
    ]);
    repo = AttendanceRepositoryImpl(AttendanceRemoteDataSource(db));
  });

  CollectionReference<Map<String, dynamic>> records(String soldier) =>
      db.collection('Users').doc(soldier).collection('Attendance');

  group('AttendanceModel', () {
    test('reads isInsideCamp and the date&time display string', () {
      final r = AttendanceModel.fromMap('a', '2023-07-05 08:00:00',
          {'isInsideCamp': false, 'date&time': 'Wed 5 Jul 2023 17:45:10'});
      expect(r.isInsideCamp, isFalse);
      expect(r.timestamp, DateTime(2023, 7, 5, 17, 45, 10));
    });

    test('falls back to the doc id when date&time is unreadable', () {
      final r = AttendanceModel.fromMap('a', '2023-07-05 08:00:00', {});
      expect(r.timestamp, DateTime(2023, 7, 5, 8));
      expect(r.isInsideCamp, isFalse);
    });

    test('toMap uses the exact field names', () {
      expect(
          AttendanceModel.toMap(
              buildAttendance(timestamp: DateTime(2023, 7, 5, 8, 0, 1))),
          {'isInsideCamp': true, 'date&time': 'Wed 5 Jul 2023 08:00:01'});
    });
  });

  test('watchForSoldier returns the soldier\'s records', () async {
    final result = await repo.watchForSoldier('Tan Ah Kow').first;
    final record = result.getOrElse(() => []).single;
    expect(record.id, '2023-07-04 08:00:00');
    expect(record.timestamp, DateTime(2023, 7, 4, 8));
  });

  test('bookInOut writes the record and currentAttendance together (R10)',
      () async {
    final at = DateTime(2023, 7, 5, 18, 5, 30);
    expect(await repo.bookInOut('Tan Ah Kow', false, at),
        const Right<Failure, Unit>(unit));

    final doc = await records('Tan Ah Kow').doc('2023-07-05 18:05:30').get();
    expect(doc.data(),
        {'isInsideCamp': false, 'date&time': 'Wed 5 Jul 2023 18:05:30'});
    final user = await db.collection('Users').doc('Tan Ah Kow').get();
    expect(user.data()!['currentAttendance'], 'Outside');
    expect(user.data()!['rank'], 'CPL');

    await repo.bookInOut('Tan Ah Kow', true, at.add(const Duration(hours: 1)));
    expect(
        (await db.collection('Users').doc('Tan Ah Kow').get())
            .data()!['currentAttendance'],
        'Inside Camp');
  });

  test('update changes date&time and keeps the doc id and flag', () async {
    final record = buildAttendance(
        id: '2023-07-04 08:00:00', timestamp: DateTime(2023, 7, 4, 9, 15));
    await repo.update(record.copyWith(isInsideCamp: false));

    final doc = await records('Tan Ah Kow').doc('2023-07-04 08:00:00').get();
    expect(doc.data(),
        {'isInsideCamp': true, 'date&time': 'Tue 4 Jul 2023 09:15:00'});
  });

  test('delete removes the record', () async {
    await repo.delete(buildAttendance(id: '2023-07-04 08:00:00'));
    expect((await records('Tan Ah Kow').get()).docs, isEmpty);
  });

  test('watchAll returns every soldier\'s records with soldier ids', () async {
    await repo.bookInOut('Lee Wei', true, DateTime(2023, 7, 5, 7));
    final all = (await repo.watchAll().first).getOrElse(() => []);
    expect({for (final r in all) r.soldierId}, {'Tan Ah Kow', 'Lee Wei'});
  });

  test('update of a missing record is a Left', () async {
    expect((await repo.update(buildAttendance(id: 'ghost'))).isLeft(), isTrue);
  });

  test('errors become Left', () async {
    final remote = _MockRemote();
    when(() => remote.watchAll())
        .thenAnswer((_) => Stream.error(const ServerException('down')));
    expect(await AttendanceRepositoryImpl(remote).watchAll().first,
        const Left<Failure, List<AttendanceRecord>>(ServerFailure('down')));
  });
}
