import 'package:dartz/dartz.dart';

import '../../../../core/data/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/status.dart';
import '../../domain/repositories/status_repository.dart';
import '../datasources/status_remote_data_source.dart';

class StatusRepositoryImpl implements StatusRepository {
  StatusRepositoryImpl(this._remote);

  final StatusRemoteDataSource _remote;

  @override
  ResultStream<List<Status>> watchForSoldier(String soldierId) =>
      guardStream(_remote.watchForSoldier(soldierId));

  @override
  ResultStream<List<Status>> watchAll() => guardStream(_remote.watchAll());

  @override
  Result<List<Status>> getAll() => guard(_remote.getAll);

  @override
  Result<Unit> add(Status status) => guard(() async {
        await _remote.add(status);
        return unit;
      });

  @override
  Result<Unit> update(Status previous, Status updated) => guard(() async {
        await _remote.update(previous, updated);
        return unit;
      });

  @override
  Result<Unit> delete(Status status) => guard(() async {
        await _remote.delete(status);
        return unit;
      });
}
