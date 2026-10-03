import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/guard_duty/data/datasources/duty_remote_data_source.dart';
import 'package:trooptrak_final_application/features/guard_duty/data/repositories/duty_repository_impl.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/services/duty_points.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/firestore_seed.dart';

void main() {
  late FakeFirebaseFirestore db;
  late DutyRepositoryImpl repo;

  Future<num> pointsOf(String name) async =>
      (await db.collection('Users').doc(name).get()).data()!['points'] as num;

  setUp(() async {
    db = await seedFirestore(
      soldiers: [
        SeededSoldier(soldierDoc(points: 2)),
        SeededSoldier(soldierDoc(name: 'Lee Wei', rank: '2LT', points: 1)),
      ],
      duties: [
        dutyDoc(participants: {'Tan Ah Kow': 'CPL', 'NA1': 'NA'}),
      ],
    );
    repo = DutyRepositoryImpl(DutyRemoteDataSource(db));
  });

  test('maps Appendix B fields and drops NA placeholder slots', () async {
    final duty = (await repo.watchAll().first).getOrElse(() => []).single;
    expect(duty.start, DateTime(2023, 7, 7, 8));
    expect(duty.dayType, 'Weekday (Friday) Duty 😖');
    expect(duty.points, 1.5);
    expect(duty.participants, {'Tan Ah Kow': 'CPL'});
  });

  test('add writes exact fields and credits points atomically (K5)', () async {
    final duty = buildDuty(
      start: DateTime(2023, 7, 8, 20, 30),
      end: DateTime(2023, 7, 8, 8),
      dayType: 'Weekend (Saturday) Duty 😵‍💫',
      points: 2.5,
      participants: {'Tan Ah Kow': 'CPL', 'Lee Wei': '2LT'},
    );
    expect(
        await repo.add(duty, {
          'Tan Ah Kow': const PointsChange(add: 2.5),
          'Lee Wei': const PointsChange(add: 2.5),
        }),
        const Right<Failure, Unit>(unit));

    final docs = (await db.collection('Duties').get()).docs;
    final added = docs.singleWhere((d) => d.data()['dutyDate'] == '8 Jul 2023');
    expect(added.data(), {
      'points': 2.5,
      'dayType': 'Weekend (Saturday) Duty 😵‍💫',
      'dutyDate': '8 Jul 2023',
      'startTime': '8:30 PM',
      'endTime': '8:00 AM',
      'participants': {'Tan Ah Kow': 'CPL', 'Lee Wei': '2LT'},
    });
    expect(await pointsOf('Tan Ah Kow'), 4.5);
    expect(await pointsOf('Lee Wei'), 3.5);
  });

  test('delete removes the duty and clamps points at zero (R9)', () async {
    final duty = (await repo.watchAll().first).getOrElse(() => []).single;
    await repo.delete(duty, {'Tan Ah Kow': const PointsChange(subtract: 5)});
    expect((await db.collection('Duties').get()).docs, isEmpty);
    expect(await pointsOf('Tan Ah Kow'), 0);
  });

  test('update replaces the duty doc and applies each change', () async {
    final duty = (await repo.watchAll().first).getOrElse(() => []).single;
    await repo.update(
      duty.copyWith(participants: {'Lee Wei': '2LT'}),
      {
        'Tan Ah Kow': const PointsChange(subtract: 1.5),
        'Lee Wei': const PointsChange(add: 1.5),
      },
    );
    final stored = (await db.collection('Duties').doc(duty.id).get()).data()!;
    expect(stored['participants'], {'Lee Wei': '2LT'});
    expect(await pointsOf('Tan Ah Kow'), 0.5);
    expect(await pointsOf('Lee Wei'), 2.5);
  });

  test('a participant without a Users doc is skipped, not fatal', () async {
    final result = await repo.add(buildDuty(participants: {'Ghost': 'PTE'}),
        {'Ghost': const PointsChange(add: 1)});
    expect(result.isRight(), isTrue);
    expect((await db.collection('Users').doc('Ghost').get()).exists, isFalse);
  });
}
