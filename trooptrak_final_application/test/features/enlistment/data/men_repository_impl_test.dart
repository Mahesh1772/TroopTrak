import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/exceptions.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/enlistment/data/datasources/men_remote_data_source.dart';
import 'package:trooptrak_final_application/features/enlistment/data/repositories/men_repository_impl.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/entities/soldier_registration.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/firestore_seed.dart';

class _MockRemote extends Mock implements MenRemoteDataSource {}

void main() {
  late FakeFirebaseFirestore db;
  late MenRepositoryImpl repo;

  Future<Map<String, dynamic>?> menDocOf(String uid) async =>
      (await db.collection('Men').doc(uid).get()).data();

  setUp(() async {
    db = await seedSampleUnit();
    repo = MenRepositoryImpl(MenRemoteDataSource(db));
  });

  test('save writes exactly the R16 fields with points 0 and no QR', () async {
    final result = await repo.save(
        'uid-9', buildSoldier(name: 'Lim Bah', rank: 'PTE', points: 7));
    expect(result, const Right<Failure, Unit>(unit));
    final doc = await menDocOf('uid-9');
    expect(doc, {
      'rank': 'PTE',
      'name': 'Lim Bah',
      'company': 'Alpha',
      'platoon': '1',
      'section': '2',
      'appointment': 'Section IC',
      'rationType': 'NM',
      'bloodgroup': 'O+',
      'dob': '5 Jul 2000',
      'ord': '1 Jan 2025',
      'enlistment': '1 Jan 2023',
      'points': 0,
      'QRid': null,
    });
    expect(doc!['points'], isA<int>());
    expect(doc.containsKey('currentAttendance'), isFalse);
  });

  test('save overwrites a previous registration', () async {
    await repo.save('uid-1', buildSoldier(name: 'Lim Renamed'));
    final doc = await menDocOf('uid-1');
    expect(doc!['name'], 'Lim Renamed');
    expect(doc['QRid'], isNull);
  });

  test('get maps the doc; profile id is the trimmed name (K8)', () async {
    await db.collection('Men').doc('uid-2').set(menDoc(name: ' Lim Bah '));
    final result = await repo.get('uid-2');
    final reg = result.getOrElse(() => throw 'missing');
    expect(reg.uid, 'uid-2');
    expect(reg.profile.id, 'Lim Bah');
    expect(reg.profile.rank, 'PTE');
    expect(reg.profile.dob, DateTime(2000, 7, 5));
    expect(reg.profile.points, 0);
    expect(reg.qrId, isNull);
  });

  test('get tolerates source placeholder dates (K17)', () async {
    await db.collection('Men').doc('uid-3').set({
      ...menDoc(),
      'dob': 'Date of Birth',
      'ord': 'Date of ORD',
      'enlistment': 'Enlishment',
    });
    final reg = (await repo.get('uid-3')).getOrElse(() => throw 'missing');
    expect([reg.profile.dob, reg.profile.ord, reg.profile.enlistment],
        [null, null, null]);
  });

  test('get of a missing registration is a NotFound Left', () async {
    final result = await repo.get('ghost');
    expect(result.isLeft(), isTrue);
    result.leftMap((f) => expect(f, isA<NotFoundFailure>()));
  });

  test('exists reflects Men/{uid}', () async {
    expect(await repo.exists('uid-1'), const Right<Failure, bool>(true));
    expect(await repo.exists('ghost'), const Right<Failure, bool>(false));
  });

  test('setQrId merges QRid only and null clears it (R15)', () async {
    await repo.setQrId('uid-1', 'qr-new');
    var doc = await menDocOf('uid-1');
    expect(doc!['QRid'], 'qr-new');
    expect(doc['name'], 'Lim Bah');
    expect(doc['rank'], 'PTE');

    await repo.setQrId('uid-1', null);
    doc = await menDocOf('uid-1');
    expect(doc!['QRid'], isNull);
    expect(doc['name'], 'Lim Bah');
  });

  test('findByQrId returns the holder, or null when nobody has it', () async {
    final found = (await repo.findByQrId('qr-123')).getOrElse(() => null);
    expect(found?.uid, 'uid-1');
    expect(found?.profile.name, 'Lim Bah');
    expect(found?.qrId, 'qr-123');
    expect(await repo.findByQrId('qr-unknown'),
        const Right<Failure, SoldierRegistration?>(null));
  });

  test('errors become Left', () async {
    registerFallbackValue(buildSoldier());
    final remote = _MockRemote();
    when(() => remote.findByQrId(any()))
        .thenThrow(const ServerException('down'));
    when(() => remote.save(any(), any()))
        .thenThrow(const ServerException('down'));
    repo = MenRepositoryImpl(remote);
    expect(await repo.findByQrId('x'),
        const Left<Failure, SoldierRegistration?>(ServerFailure('down')));
    expect(await repo.save('u', buildSoldier()),
        const Left<Failure, Unit>(ServerFailure('down')));
  });
}
