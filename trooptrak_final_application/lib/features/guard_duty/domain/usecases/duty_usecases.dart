import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/repositories/soldier_repository.dart';
import '../../../statuses/domain/repositories/status_repository.dart';
import '../../../statuses/domain/services/eligibility_service.dart';
import '../entities/duty.dart';
import '../repositories/duty_repository.dart';
import '../services/duty_points.dart';

class WatchDuties implements StreamUseCase<List<Duty>, NoParams> {
  const WatchDuties(this._repository);

  final DutyRepository _repository;

  @override
  ResultStream<List<Duty>> call(NoParams params) => _repository.watchAll();
}

const tooManySlots = 'A duty has at most ${Duty.maxSlots} slots.';

/// Points and day label always follow the duty date (R7).
Duty _priced(Duty duty) {
  final day = DutyPoints.forDate(duty.start);
  return duty.copyWith(points: day.points, dayType: day.dayType);
}

ValidationFailure? _validate(Duty duty) =>
    duty.participants.length > Duty.maxSlots
        ? const ValidationFailure(tooManySlots)
        : null;

class AddDuty implements UseCase<Unit, Duty> {
  const AddDuty(this._repository);

  final DutyRepository _repository;

  @override
  Result<Unit> call(Duty duty) async {
    final invalid = _validate(duty);
    if (invalid != null) return Left(invalid);
    final priced = _priced(duty);
    return _repository.add(
        priced, DutyLedger.add(priced.participants, priced.points));
  }
}

class UpdateDutyParams extends Equatable {
  const UpdateDutyParams({required this.previous, required this.updated});

  final Duty previous;
  final Duty updated;

  @override
  List<Object?> get props => [previous, updated];
}

class UpdateDuty implements UseCase<Unit, UpdateDutyParams> {
  const UpdateDuty(this._repository);

  final DutyRepository _repository;

  @override
  Result<Unit> call(UpdateDutyParams params) async {
    final invalid = _validate(params.updated);
    if (invalid != null) return Left(invalid);
    final priced = _priced(params.updated.copyWith(id: params.previous.id));
    return _repository.update(
      priced,
      DutyLedger.update(
        before: params.previous.participants,
        beforePoints: params.previous.points,
        after: priced.participants,
        afterPoints: priced.points,
      ),
    );
  }
}

class DeleteDuty implements UseCase<Unit, Duty> {
  const DeleteDuty(this._repository);

  final DutyRepository _repository;

  @override
  Result<Unit> call(Duty duty) => _repository.delete(
      duty, DutyLedger.delete(duty.participants, duty.points));
}

/// R6: soldiers who may be rostered, judged on statuses active today (K2).
class GetDutyEligibleSoldiers implements UseCase<List<Soldier>, NoParams> {
  const GetDutyEligibleSoldiers(this._soldiers, this._statuses, this._clock);

  final SoldierRepository _soldiers;
  final StatusRepository _statuses;
  final Clock _clock;

  @override
  Result<List<Soldier>> call(NoParams params) async {
    final soldiers = await _soldiers.getAll();
    if (soldiers.isLeft()) return soldiers;
    final statuses = await _statuses.getAll();
    return statuses.map((all) {
      final excluded =
          EligibilityService.guardDutyExclusions(all, _clock.now());
      return [
        for (final s in soldiers.getOrElse(() => const []))
          if (!excluded.contains(s.id)) s,
      ];
    });
  }
}
