import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/repositories/soldier_repository.dart';
import '../../../statuses/domain/entities/status.dart';
import '../../../statuses/domain/repositories/status_repository.dart';
import '../../../statuses/domain/services/eligibility_service.dart';

class ConductRoster extends Equatable {
  const ConductRoster({required this.participants, required this.reasons});

  /// Soldier names, in Users order.
  final List<String> participants;

  /// Excluded soldier name → status name (R5).
  final Map<String, String> reasons;

  @override
  List<Object?> get props => [participants, reasons];
}

/// R5 roster: every soldier, minus those excluded by a status active today (K2).
ConductRoster rosterFor(
  String conductType,
  Iterable<Soldier> soldiers,
  Iterable<Status> statuses,
  DateTime today,
) {
  final excluded =
      EligibilityService.conductExclusions(conductType, statuses, today);
  final reasons = <String, String>{};
  final participants = <String>[];
  for (final s in soldiers) {
    final reason = excluded[s.id];
    if (reason == null) {
      participants.add(s.name);
    } else {
      reasons[s.name] = reason;
    }
  }
  return ConductRoster(participants: participants, reasons: reasons);
}

class BuildConductRoster implements UseCase<ConductRoster, String> {
  const BuildConductRoster(this._soldiers, this._statuses, this._clock);

  final SoldierRepository _soldiers;
  final StatusRepository _statuses;
  final Clock _clock;

  @override
  Result<ConductRoster> call(String conductType) async {
    final soldiers = await _soldiers.getAll();
    if (soldiers.isLeft()) return soldiers.map((_) => _empty);
    final all = soldiers.getOrElse(() => const []);
    final statuses = await _statuses.getAll();
    return statuses.map((s) => rosterFor(conductType, all, s, _clock.now()));
  }

  static const _empty = ConductRoster(participants: [], reasons: {});
}
