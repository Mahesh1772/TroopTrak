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
import '../services/participation_ticks.dart';

enum ConductGroup { participants, nonParticipants }

class ConductBreakdown extends Equatable {
  const ConductBreakdown({required this.conduct, required this.roster});

  final Conduct conduct;
  final List<Soldier> roster;

  List<Soldier> get participants => [
        for (final s in roster)
          if (conduct.includes(s.name)) s
      ];

  List<Soldier> get nonParticipants => [
        for (final s in roster)
          if (!conduct.includes(s.name)) s
      ];

  List<Soldier> members(ConductGroup group) => switch (group) {
        ConductGroup.participants => participants,
        ConductGroup.nonParticipants => nonParticipants,
      };

  /// The appointment of a participant, the reason a non-participant is out.
  String noteFor(Soldier soldier) => conduct.includes(soldier.name)
      ? soldier.appointment
      : conduct.reasonFor(soldier.name);

  /// One tick per soldier, in roster order.
  ParticipationTicks get ticks =>
      participationTicks(roster: roster, conduct: conduct);

  /// Case-insensitive name search over the roster, as the source details page.
  ConductBreakdown search(String query) {
    final q = query.toLowerCase();
    return ConductBreakdown(
      conduct: conduct,
      roster: [
        for (final s in roster)
          if (q.isEmpty || s.name.toLowerCase().contains(q)) s,
      ],
    );
  }

  bool get isEmpty => roster.isEmpty;

  @override
  List<Object?> get props => [conduct, roster];
}

ConductBreakdown breakdownOf(Conduct conduct, Iterable<Soldier> soldiers) =>
    ConductBreakdown(conduct: conduct, roster: soldiers.toList());

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
