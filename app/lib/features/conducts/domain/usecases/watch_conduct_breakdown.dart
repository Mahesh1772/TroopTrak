import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/repositories/soldier_repository.dart';
import '../entities/conduct.dart';
import '../repositories/conduct_repository.dart';

class ConductBreakdown extends Equatable {
  const ConductBreakdown({
    required this.conduct,
    required this.participants,
    required this.nonParticipants,
  });

  final Conduct conduct;
  final List<Soldier> participants;
  final List<Soldier> nonParticipants;

  /// Case-insensitive name search over both lists, as the source details page.
  ConductBreakdown search(String query) {
    final q = query.toLowerCase();
    bool keep(Soldier s) => q.isEmpty || s.name.toLowerCase().contains(q);
    return ConductBreakdown(
      conduct: conduct,
      participants: participants.where(keep).toList(),
      nonParticipants: nonParticipants.where(keep).toList(),
    );
  }

  bool get isEmpty => participants.isEmpty && nonParticipants.isEmpty;

  @override
  List<Object?> get props => [conduct, participants, nonParticipants];
}

ConductBreakdown breakdownOf(Conduct conduct, Iterable<Soldier> soldiers) {
  final yes = <Soldier>[];
  final no = <Soldier>[];
  for (final s in soldiers) {
    (conduct.includes(s.name) ? yes : no).add(s);
  }
  return ConductBreakdown(
      conduct: conduct, participants: yes, nonParticipants: no);
}

/// The conduct and every soldier split by participation, kept live.
class WatchConductBreakdown implements StreamUseCase<ConductBreakdown, String> {
  const WatchConductBreakdown(this._conducts, this._soldiers);

  final ConductRepository _conducts;
  final SoldierRepository _soldiers;

  @override
  ResultStream<ConductBreakdown> call(String conductId) => Rx.combineLatest2(
        _conducts.watchById(conductId),
        _soldiers.watchAll(),
        (Either<Failure, Conduct> conduct,
                Either<Failure, List<Soldier>> soldiers) =>
            conduct.flatMap((c) => soldiers.map((s) => breakdownOf(c, s))),
      );
}
