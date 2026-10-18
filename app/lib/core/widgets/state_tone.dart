import 'dart:ui' show Color;

import '../../features/statuses/domain/services/parade_state.dart';
import '../theme/app_palette.dart';

enum StateTone {
  inCamp,
  excuse,
  leave,
  medical,
  out,
  accent;

  Color fill(AppPalette palette) => switch (this) {
        inCamp => palette.success,
        excuse => palette.statusExcuse,
        leave => palette.statusLeave,
        medical => palette.statusMedical,
        out => palette.tickOff,
        accent => palette.accent,
      };
}

extension ParadeStateTone on ParadeState {
  StateTone get tone => switch (this) {
        ParadeState.inCamp => StateTone.inCamp,
        ParadeState.excuse => StateTone.excuse,
        ParadeState.medical => StateTone.medical,
        ParadeState.leave => StateTone.leave,
        ParadeState.out => StateTone.out,
      };
}
