import 'package:dartz/dartz.dart';

import '../../../../core/data/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/duty.dart';
import '../../domain/repositories/duty_repository.dart';
import '../../domain/services/duty_points.dart';
import '../datasources/duty_remote_data_source.dart';

class DutyRepositoryImpl implements DutyRepository {
  DutyRepositoryImpl(this._remote);

  final DutyRemoteDataSource _remote;

  @override
  ResultStream<List<Duty>> watchAll() => guardStream(_remote.watchAll());

  @override
  Result<Unit> add(Duty duty, Map<String, PointsChange> changes) =>
      guard(() async {
        await _remote.add(duty, changes);
        return unit;
      });

  @override
  Result<Unit> update(Duty duty, Map<String, PointsChange> changes) =>
      guard(() async {
        await _remote.update(duty, changes);
        return unit;
      });

  @override
  Result<Unit> delete(Duty duty, Map<String, PointsChange> changes) =>
      guard(() async {
        await _remote.delete(duty, changes);
        return unit;
      });
}
