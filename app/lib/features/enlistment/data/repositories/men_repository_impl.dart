import 'package:dartz/dartz.dart';

import '../../../../core/data/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../domain/entities/soldier_registration.dart';
import '../../domain/repositories/men_repository.dart';
import '../datasources/men_remote_data_source.dart';

class MenRepositoryImpl implements MenRepository {
  MenRepositoryImpl(this._remote);

  final MenRemoteDataSource _remote;

  @override
  Result<bool> exists(String uid) => guard(() => _remote.exists(uid));

  @override
  Result<SoldierRegistration> get(String uid) => guard(() => _remote.get(uid));

  @override
  ResultStream<SoldierRegistration> watch(String uid) =>
      guardStream(_remote.watch(uid));

  @override
  Result<Unit> updateProfile(String uid, Soldier profile) => guard(() async {
        await _remote.updateProfile(uid, profile);
        return unit;
      });

  @override
  Result<Unit> save(String uid, Soldier profile) => guard(() async {
        await _remote.save(uid, profile);
        return unit;
      });

  @override
  Result<Unit> setQrId(String uid, String? qrId) => guard(() async {
        await _remote.setQrId(uid, qrId);
        return unit;
      });

  @override
  Result<SoldierRegistration?> findByQrId(String qrId) =>
      guard(() => _remote.findByQrId(qrId));
}
