import 'package:dartz/dartz.dart';

import '../../../../core/data/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/conduct.dart';
import '../../domain/repositories/conduct_repository.dart';
import '../datasources/conduct_remote_data_source.dart';

class ConductRepositoryImpl implements ConductRepository {
  ConductRepositoryImpl(this._remote);

  final ConductRemoteDataSource _remote;

  @override
  ResultStream<List<Conduct>> watchAll() => guardStream(_remote.watchAll());

  @override
  ResultStream<List<Conduct>> watchOnDay(DateTime day) =>
      guardStream(_remote.watchOnDay(day));

  @override
  ResultStream<Conduct> watchById(String id) =>
      guardStream(_remote.watchById(id));

  @override
  Result<Unit> add(Conduct conduct) => guard(() async {
        await _remote.add(conduct);
        return unit;
      });

  @override
  Result<Unit> update(Conduct conduct) => guard(() async {
        await _remote.update(conduct);
        return unit;
      });

  @override
  Result<Unit> delete(String id) => guard(() async {
        await _remote.delete(id);
        return unit;
      });
}
