import 'package:dartz/dartz.dart';

import '../../../../core/constants/conduct_types.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/conduct.dart';
import '../repositories/conduct_repository.dart';

class WatchConductsOnDay implements StreamUseCase<List<Conduct>, DateTime> {
  const WatchConductsOnDay(this._repository);

  final ConductRepository _repository;

  @override
  ResultStream<List<Conduct>> call(DateTime day) => _repository.watchOnDay(day);
}

ValidationFailure? _validate(Conduct conduct) {
  if (!ConductTypes.all.contains(conduct.type)) {
    return const ValidationFailure('Bruh select!');
  }
  if (conduct.name.trim().isEmpty) {
    return const ValidationFailure('Oi can add conduct please?');
  }
  if (conduct.end.isBefore(conduct.start)) {
    return const ValidationFailure(endBeforeStartTime);
  }
  return null;
}

/// Source forms accepted any pair of times (user: refuse end < start).
const endBeforeStartTime = 'End time cannot be before the start time.';

class AddConduct implements UseCase<Unit, Conduct> {
  const AddConduct(this._repository);

  final ConductRepository _repository;

  @override
  Result<Unit> call(Conduct conduct) async {
    final invalid = _validate(conduct);
    if (invalid != null) return Left(invalid);
    return _repository.add(conduct.copyWith(name: conduct.name.trim()));
  }
}

class UpdateConduct implements UseCase<Unit, Conduct> {
  const UpdateConduct(this._repository);

  final ConductRepository _repository;

  @override
  Result<Unit> call(Conduct conduct) async {
    final invalid = _validate(conduct);
    if (invalid != null) return Left(invalid);
    return _repository.update(conduct.copyWith(name: conduct.name.trim()));
  }
}

class DeleteConduct implements UseCase<Unit, String> {
  const DeleteConduct(this._repository);

  final ConductRepository _repository;

  @override
  Result<Unit> call(String id) => _repository.delete(id);
}
