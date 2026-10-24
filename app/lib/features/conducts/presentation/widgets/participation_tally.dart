import '../../../../core/widgets/state_tone.dart';
import '../../../../core/widgets/tally_strip.dart';
import '../../domain/services/participation_ticks.dart';

/// Accent for a soldier who took part, the "out" grey for one who did not, and
/// the signed-in soldier's own tick ringed.
List<TallyTick> participationTallyTicks(ParticipationTicks ticks) => [
      for (final tick in ticks.ticks)
        TallyTick(
          tone: tick.tookPart ? StateTone.accent : StateTone.out,
          title: '${tick.soldier.rank} ${tick.soldier.name}',
          detail: tick.tookPart ? 'participating' : 'not participating',
          isSelf: tick.isSelf,
        ),
    ];
