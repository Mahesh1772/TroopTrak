import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/conducts/data/datasources/conduct_remote_data_source.dart';
import 'package:trooptrak_final_application/features/conducts/data/repositories/conduct_repository_impl.dart';
import 'package:trooptrak_final_application/features/conducts/domain/entities/conduct.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/firestore_seed.dart';

void main() {
  late FakeFirebaseFirestore db;
  late ConductRepositoryImpl repo;

  setUp(() async {
    db = await seedFirestore(conducts: [
      conductDoc(),
      conductDoc(
          name: 'IPPT Test',
          type: 'IPPT',
          startDate: '6 Jul 2023',
          startTime: '2:00 PM',
          endTime: '4:30 PM',
          participants: ['Lee Wei'],
          soldierReason: {'Tan Ah Kow': 'Ex RMJ'}),
    ]);
    repo = ConductRepositoryImpl(ConductRemoteDataSource(db));
  });

  test('maps Appendix B fields, combining date and jm times', () async {
    final all = (await repo.watchAll().first).getOrElse(() => []);
    final ippt = all.singleWhere((c) => c.type == 'IPPT');
    expect(ippt.name, 'IPPT Test');
    expect(ippt.start, DateTime(2023, 7, 6, 14));
    expect(ippt.end, DateTime(2023, 7, 6, 16, 30));
    expect(ippt.participants, ['Lee Wei']);
    expect(ippt.soldierReason, {'Tan Ah Kow': 'Ex RMJ'});
  });

  test('watchOnDay returns conducts whose startDate is that day (R13)',
      () async {
    final day = (await repo.watchOnDay(DateTime(2023, 7, 5, 18)).first)
        .getOrElse(() => []);
    expect(day.map((c) => c.name), ['Morning Run']);
  });

  test('add writes exactly the source fields and formats', () async {
    await repo.add(buildConduct(
      name: 'Night Walk',
      type: 'Route March',
      start: DateTime(2023, 7, 7, 19, 5),
      end: DateTime(2023, 7, 7, 23, 45),
      participants: ['Tan Ah Kow', 'Lim Bah'],
      soldierReason: {'Lee Wei': 'OL'},
    ));
    final snap = await db
        .collection('Conducts')
        .where('conductName', isEqualTo: 'Night Walk')
        .get();
    expect(snap.docs.single.data(), {
      'conductName': 'Night Walk',
      'conductType': 'Route March',
      'startDate': '7 Jul 2023',
      'startTime': '7:05 PM',
      'endTime': '11:45 PM',
      'participants': ['Tan Ah Kow', 'Lim Bah'],
      'soldierReason': {'Lee Wei': 'OL'},
    });
  });

  test('watchById follows updates and turns NotFound after delete', () async {
    final id = (await db.collection('Conducts').get()).docs.first.id;
    final events = <Either<Failure, Conduct>>[];
    final sub = repo.watchById(id).listen(events.add);
    await Future<void>.delayed(Duration.zero);

    final first = events.first.getOrElse(() => throw 'x');
    await repo.update(first.copyWith(participants: ['Lim Bah']));
    await Future<void>.delayed(Duration.zero);
    expect(events.last.getOrElse(() => throw 'x').participants, ['Lim Bah']);

    await repo.delete(id);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(events.last.isLeft(), isTrue);
  });

  test('missing or odd fields do not break the mapping', () async {
    await db.collection('Conducts').doc('odd').set({
      'conductName': 'Legacy',
      'startDate': 'Date:',
      'startTime': 'Start Time:',
    });
    final odd = (await repo.watchById('odd').first).getOrElse(() => throw 'x');
    expect(odd.participants, isEmpty);
    expect(odd.soldierReason, isEmpty);
    expect(odd.start, DateTime(1970));
  });
}
