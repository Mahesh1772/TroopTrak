import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/soldier.dart';
import '../repositories/soldier_repository.dart';

class WatchSoldiers implements StreamUseCase<List<Soldier>, NoParams> {
  const WatchSoldiers(this._repository);

  final SoldierRepository _repository;

  @override
  ResultStream<List<Soldier>> call(NoParams params) => _repository.watchAll();
}

class WatchSoldier implements StreamUseCase<Soldier, String> {
  const WatchSoldier(this._repository);

  final SoldierRepository _repository;

  @override
  ResultStream<Soldier> call(String id) => _repository.watchById(id);
}

class GetSoldiers implements UseCase<List<Soldier>, NoParams> {
  const GetSoldiers(this._repository);

  final SoldierRepository _repository;

  @override
  Result<List<Soldier>> call(NoParams params) => _repository.getAll();
}

/// R17: id is the trimmed name, starts in camp with zero points. K13: no overwrite.
class AddSoldier implements UseCase<Unit, Soldier> {
  const AddSoldier(this._repository, this._clock);

  final SoldierRepository _repository;
  final Clock _clock;

  @override
  Result<Unit> call(Soldier soldier) async {
    final name = soldier.name.trim();
    if (name.isEmpty) return const Left(ValidationFailure('Name is required.'));

    final exists = await _repository.exists(name);
    return exists.fold<FutureOr<Either<Failure, Unit>>>(
      Left.new,
      (found) => found
          ? Left(ValidationFailure('A soldier named $name already exists.'))
          : _repository.add(
              soldier.copyWith(id: name, name: name, isInCamp: true, points: 0),
              createdAt: _clock.now(),
            ),
    );
  }
}

class UpdateSoldier implements UseCase<Unit, Soldier> {
  const UpdateSoldier(this._repository);

  final SoldierRepository _repository;

  @override
  Result<Unit> call(Soldier soldier) {
    final name = soldier.name.trim();
    if (name.isEmpty) {
      return Future.value(const Left(ValidationFailure('Name is required.')));
    }
    return _repository.update(soldier.copyWith(name: name));
  }
}

class DeleteSoldier implements UseCase<Unit, String> {
  const DeleteSoldier(this._repository);

  final SoldierRepository _repository;

  @override
  Result<Unit> call(String id) => _repository.delete(id);
}

class PointsParams extends Equatable {
  const PointsParams(this.soldierId, this.value);

  final String soldierId;
  final double value;

  @override
  List<Object?> get props => [soldierId, value];
}

class SetSoldierPoints implements UseCase<Unit, PointsParams> {
  const SetSoldierPoints(this._repository);

  final SoldierRepository _repository;

  @override
  Result<Unit> call(PointsParams params) => _repository.setPoints(
        params.soldierId,
        Soldier.pointsAfter(params.value, 0),
      );
}

class AdjustSoldierPoints implements UseCase<Unit, PointsParams> {
  const AdjustSoldierPoints(this._repository);

  final SoldierRepository _repository;

  @override
  Result<Unit> call(PointsParams params) =>
      _repository.adjustPoints(params.soldierId, params.value);
}
