import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

/// R11 list for one soldier: newest first, future records hidden.
class WatchAttendance implements StreamUseCase<List<AttendanceRecord>, String> {
  const WatchAttendance(this._repository, this._clock);

  final AttendanceRepository _repository;
  final Clock _clock;

  @override
  ResultStream<List<AttendanceRecord>> call(String soldierId) => _repository
      .watchForSoldier(soldierId)
      .map((r) => r.map((records) => visibleAttendance(records, _clock.now())));
}

class WatchAllAttendance
    implements StreamUseCase<List<AttendanceRecord>, NoParams> {
  const WatchAllAttendance(this._repository);

  final AttendanceRepository _repository;

  @override
  ResultStream<List<AttendanceRecord>> call(NoParams params) =>
      _repository.watchAll();
}

class BookInOutParams extends Equatable {
  const BookInOutParams(this.soldierId, {required this.isInsideCamp});

  final String soldierId;
  final bool isInsideCamp;

  @override
  List<Object?> get props => [soldierId, isInsideCamp];
}

class BookInOut implements UseCase<Unit, BookInOutParams> {
  const BookInOut(this._repository, this._clock);

  final AttendanceRepository _repository;
  final Clock _clock;

  @override
  Result<Unit> call(BookInOutParams params) => _repository.bookInOut(
        params.soldierId,
        params.isInsideCamp,
        _clock.now(),
      );
}

class UpdateAttendance implements UseCase<Unit, AttendanceRecord> {
  const UpdateAttendance(this._repository);

  final AttendanceRepository _repository;

  @override
  Result<Unit> call(AttendanceRecord record) => _repository.update(record);
}

class DeleteAttendance implements UseCase<Unit, AttendanceRecord> {
  const DeleteAttendance(this._repository);

  final AttendanceRepository _repository;

  @override
  Result<Unit> call(AttendanceRecord record) => _repository.delete(record);
}
