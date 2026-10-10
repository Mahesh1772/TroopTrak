import 'package:dartz/dartz.dart';

import '../../../../core/data/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/soldier.dart';
import '../../domain/repositories/soldier_repository.dart';
import '../datasources/soldier_remote_data_source.dart';

class SoldierRepositoryImpl implements SoldierRepository {
  SoldierRepositoryImpl(this._remote);

  final SoldierRemoteDataSource _remote;

  @override
  ResultStream<List<Soldier>> watchAll() => guardStream(_remote.watchAll());

  @override
  ResultStream<Soldier> watchById(String id) =>
      guardStream(_remote.watchById(id));

  @override
  Result<List<Soldier>> getAll() => guard(_remote.getAll);

  @override
  Result<bool> exists(String id) => guard(() => _remote.exists(id));

  @override
  Result<Unit> add(Soldier soldier, {required DateTime createdAt}) =>
      guard(() async {
        await _remote.add(soldier, createdAt);
        return unit;
      });

  @override
  Result<Unit> update(Soldier soldier) => guard(() async {
        await _remote.update(soldier);
        return unit;
      });

  @override
  Result<Unit> delete(String id) => guard(() async {
        await _remote.delete(id);
        return unit;
      });
}
