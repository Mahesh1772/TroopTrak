import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/exceptions.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/soldiers/data/datasources/soldier_remote_data_source.dart';
import 'package:trooptrak_final_application/features/soldiers/data/repositories/soldier_repository_impl.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/firestore_seed.dart';

class _MockRemote extends Mock implements SoldierRemoteDataSource {}

void main() {
  late FakeFirebaseFirestore db;
  late SoldierRepositoryImpl repo;

  Future<void> useDb(FakeFirebaseFirestore seeded) async {
    db = seeded;
    repo = SoldierRepositoryImpl(SoldierRemoteDataSource(db));
  }

  setUp(() => useDb(FakeFirebaseFirestore()));

  test('getAll and watchAll return seeded soldiers', () async {
    await useDb(await seedSampleUnit());
    final all = (await repo.getAll()).getOrElse(() => []);
    expect(all.map((s) => s.id), containsAll(['Tan Ah Kow', 'Lee Wei']));
    final first = await repo.watchAll().first;
    expect(first.getOrElse(() => []).length, 2);
  });

  test('watchAll emits again when a soldier is added', () async {
    final emissions = <int>[];
    final sub = repo
        .watchAll()
        .listen((r) => emissions.add(r.getOrElse(() => []).length));
    await Future<void>.delayed(Duration.zero);
    await db
        .collection('Users')
        .doc('New Guy')
        .set(soldierDoc(name: 'New Guy'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(emissions.first, 0);
    expect(emissions.last, 1);
  });

  test('watchById emits the soldier, then NotFound once deleted', () async {
    await useDb(await seedSampleUnit());
    final events = <Either<Failure, Soldier>>[];
    final sub = repo.watchById('Lee Wei').listen(events.add);
    await Future<void>.delayed(Duration.zero);
    await db.collection('Users').doc('Lee Wei').delete();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(events.first.getOrElse(() => throw 'x').rank, '2LT');
    expect(events.last.isLeft(), isTrue);
    events.last.leftMap((f) => expect(f, isA<NotFoundFailure>()));
  });

  test('add writes the Users doc and an initial attendance record (R17)',
      () async {
    final createdAt = DateTime(2023, 7, 5, 9, 30, 15);
    final result =
        await repo.add(buildSoldier(name: 'Lim Bah'), createdAt: createdAt);
    expect(result, const Right<Failure, Unit>(unit));

    final user = await db.collection('Users').doc('Lim Bah').get();
    expect(user.data()!['currentAttendance'], 'Inside Camp');
    expect(user.data()!['points'], 0.0);
    expect(user.data()!['bloodgroup'], 'O+');

    final att = await db
        .collection('Users')
        .doc('Lim Bah')
        .collection('Attendance')
        .get();
    expect(att.docs.single.id, '2023-07-05 09:30:15');
    expect(att.docs.single.data(),
        {'isInsideCamp': true, 'date&time': 'Wed 5 Jul 2023 09:30:15'});
  });

  test('exists reflects the Users doc', () async {
    await useDb(await seedSampleUnit());
    expect(await repo.exists('Tan Ah Kow'), const Right<Failure, bool>(true));
    expect(await repo.exists('Nobody'), const Right<Failure, bool>(false));
  });

  test('update changes profile fields only and keeps the doc id', () async {
    await useDb(await seedFirestore(soldiers: [
      SeededSoldier(soldierDoc(points: 4, currentAttendance: 'Outside')),
    ]));
    await repo.update(
        buildSoldier(name: 'Tan Renamed', id: 'Tan Ah Kow', rank: 'CFC'));

    final doc = (await db.collection('Users').doc('Tan Ah Kow').get()).data()!;
    expect(doc['name'], 'Tan Renamed');
    expect(doc['rank'], 'CFC');
    expect(doc['points'], 4);
    expect(doc['currentAttendance'], 'Outside');
  });

  test('update of a missing soldier is a Left', () async {
    expect((await repo.update(buildSoldier(id: 'ghost'))).isLeft(), isTrue);
  });

  test('delete removes statuses, attendance and the doc (R14)', () async {
    await useDb(await seedSampleUnit());
    final user = db.collection('Users').doc('Tan Ah Kow');
    for (var i = 0; i < 520; i++) {
      await user
          .collection('Attendance')
          .doc('2023-01-01 00:00:${i.toString().padLeft(3, '0')}')
          .set(attendanceDoc());
    }

    expect(await repo.delete('Tan Ah Kow'), const Right<Failure, Unit>(unit));
    expect((await user.get()).exists, isFalse);
    expect((await user.collection('Statuses').get()).docs, isEmpty);
    expect((await user.collection('Attendance').get()).docs, isEmpty);
    expect((await db.collection('Users').doc('Lee Wei').get()).exists, isTrue);
  });

  group('errors become Left', () {
    late _MockRemote remote;

    setUp(() {
      remote = _MockRemote();
      repo = SoldierRepositoryImpl(remote);
    });

    test('for futures', () async {
      when(() => remote.getAll()).thenThrow(const ServerException('down'));
      expect(await repo.getAll(),
          const Left<Failure, List<Soldier>>(ServerFailure('down')));
    });

    test('for streams', () async {
      when(() => remote.watchAll())
          .thenAnswer((_) => Stream.error(const ServerException('down')));
      expect(await repo.watchAll().first,
          const Left<Failure, List<Soldier>>(ServerFailure('down')));
    });
  });
}
