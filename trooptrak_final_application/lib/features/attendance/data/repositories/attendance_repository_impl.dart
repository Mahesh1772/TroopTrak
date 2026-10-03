import 'package:dartz/dartz.dart';

import '../../../../core/data/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._remote);

  final AttendanceRemoteDataSource _remote;

  @override
  ResultStream<List<AttendanceRecord>> watchForSoldier(String soldierId) =>
      guardStream(_remote.watchForSoldier(soldierId));

  @override
  ResultStream<List<AttendanceRecord>> watchAll() =>
      guardStream(_remote.watchAll());

  @override
  Result<Unit> bookInOut(String soldierId, bool isInsideCamp, DateTime at) =>
      guard(() async {
        await _remote.bookInOut(soldierId, isInsideCamp, at);
        return unit;
      });

  @override
  Result<Unit> update(AttendanceRecord record) => guard(() async {
        await _remote.update(record);
        return unit;
      });

  @override
  Result<Unit> delete(AttendanceRecord record) => guard(() async {
        await _remote.delete(record);
        return unit;
      });
}
