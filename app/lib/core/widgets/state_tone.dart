import 'dart:ui' show Color;

import '../../features/statuses/domain/entities/status.dart';
import '../../features/statuses/domain/services/parade_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

const _tint = 0.16;
const _tintStrong = 0.18;

enum StateTone {
  inCamp,
  excuse,
  leave,
  medical,
  out,
  accent,
  duty;

  Color fill(AppPalette palette) => switch (this) {
        inCamp => palette.success,
        excuse => palette.statusExcuse,
        leave => palette.statusLeave,
        medical => palette.statusMedical,
        out => palette.tickOff,
        accent => palette.accent,
        duty => palette.duty,
      };

  /// Card gradient from [fill] to a darker end; tones without one stay flat.
  List<Color> gradient(AppPalette palette) => switch (this) {
        excuse => [fill(palette), AppColors.statusExcuseEnd],
        leave => [fill(palette), AppColors.statusLeaveEnd],
        medical => [fill(palette), AppColors.statusMedicalEnd],
        _ => [fill(palette), fill(palette)],
      };

  /// Legible text colour for this tone on a card.
  Color text(AppPalette palette) => switch (this) {
        inCamp => palette.successText,
        excuse => palette.excuseText,
        leave => palette.leaveText,
        medical => palette.medicalText,
        out => palette.secondaryText,
        accent => palette.accentText,
        duty => palette.duty,
      };

  /// Soft background that sits behind [text].
  Color tint(AppPalette palette) => switch (this) {
        out => palette.hover,
        medical || accent => fill(palette).withValues(alpha: _tintStrong),
        _ => fill(palette).withValues(alpha: _tint),
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

extension StatusTone on Status {
  StateTone get tone => switch (this) {
        Status(isLeave: true) => StateTone.leave,
        Status(isMedicalAppointment: true) => StateTone.medical,
        _ => StateTone.excuse,
      };
}
