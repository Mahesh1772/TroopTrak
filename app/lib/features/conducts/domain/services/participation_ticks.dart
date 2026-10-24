import 'package:equatable/equatable.dart';

import '../../../soldiers/domain/entities/soldier.dart';
import '../entities/conduct.dart';

class ParticipationTick extends Equatable {
  const ParticipationTick({
    required this.soldier,
    required this.tookPart,
    this.isSelf = false,
  });

  final Soldier soldier;
  final bool tookPart;
  final bool isSelf;

  @override
  List<Object?> get props => [soldier, tookPart, isSelf];
}

/// One tick per rostered soldier, in roster order.
class ParticipationTicks extends Equatable {
  const ParticipationTicks(this.ticks);

  final List<ParticipationTick> ticks;

  int get total => ticks.length;

  int get participating => ticks.where((t) => t.tookPart).length;

  int get notParticipating => total - participating;

  ParticipationTick? get self => ticks.where((t) => t.isSelf).firstOrNull;

  @override
  List<Object?> get props => [ticks];
}

/// One tick per rostered soldier whose name is in [participants].
ParticipationTicks participationTicksOf({
  required Iterable<Soldier> roster,
  required Iterable<String> participants,
  String? selfName,
}) {
  final names = participants.toSet();
  return ParticipationTicks([
    for (final soldier in roster)
      ParticipationTick(
        soldier: soldier,
        tookPart: names.contains(soldier.name),
        isSelf: soldier.name == selfName,
      ),
  ]);
}

/// R13 links soldiers to a conduct by name. Participants who are no longer on
/// the roster are not counted.
ParticipationTicks participationTicks({
  required Iterable<Soldier> roster,
  required Conduct conduct,
  String? selfName,
}) =>
    participationTicksOf(
      roster: roster,
      participants: conduct.participants,
      selfName: selfName,
    );
