import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/status_types.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/status.dart';
import '../repositories/status_repository.dart';

class WatchSoldierStatuses implements StreamUseCase<List<Status>, String> {
  const WatchSoldierStatuses(this._repository);

  final StatusRepository _repository;

  @override
  ResultStream<List<Status>> call(String soldierId) =>
      _repository.watchForSoldier(soldierId);
}

class WatchAllStatuses implements StreamUseCase<List<Status>, NoParams> {
  const WatchAllStatuses(this._repository);

  final StatusRepository _repository;

  @override
  ResultStream<List<Status>> call(NoParams params) => _repository.watchAll();
}

/// Every soldier's statuses that are active today (R2).
class GetActiveStatuses implements UseCase<List<Status>, NoParams> {
  const GetActiveStatuses(this._repository, this._clock);

  final StatusRepository _repository;
  final Clock _clock;

  @override
  Result<List<Status>> call(NoParams params) async {
    final today = _clock.now();
    final result = await _repository.getAll();
    return result.map((all) => [
          for (final s in all)
            if (s.isActiveOn(today)) s,
        ]);
  }
}

ValidationFailure? _validate(Status status) {
  if (!StatusTypes.all.contains(status.type)) {
    return const ValidationFailure('Select a status type.');
  }
  if (status.name.trim().isEmpty) {
    return const ValidationFailure('Enter a status name.');
  }
  return null;
}

class AddStatus implements UseCase<Unit, Status> {
  const AddStatus(this._repository);

  final StatusRepository _repository;

  @override
  Result<Unit> call(Status status) async {
    final invalid = _validate(status);
    if (invalid != null) return Left(invalid);
    return _repository.add(status.copyWith(name: status.name.trim()));
  }
}

class UpdateStatusParams extends Equatable {
  const UpdateStatusParams({required this.previous, required this.updated});

  final Status previous;
  final Status updated;

  @override
  List<Object?> get props => [previous, updated];
}

class UpdateStatus implements UseCase<Unit, UpdateStatusParams> {
  const UpdateStatus(this._repository);

  final StatusRepository _repository;

  @override
  Result<Unit> call(UpdateStatusParams params) async {
    final invalid = _validate(params.updated);
    if (invalid != null) return Left(invalid);
    return _repository.update(
      params.previous,
      params.updated.copyWith(name: params.updated.name.trim()),
    );
  }
}

class DeleteStatus implements UseCase<Unit, Status> {
  const DeleteStatus(this._repository);

  final StatusRepository _repository;

  @override
  Result<Unit> call(Status status) => _repository.delete(status);
}
