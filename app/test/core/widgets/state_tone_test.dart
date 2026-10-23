import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/constants/status_types.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_state.dart';

import '../../helpers/builders.dart';

void main() {
  test('each tone is filled from its palette colour in both themes', () {
    for (final palette in [AppPalette.dark, AppPalette.light]) {
      expect(StateTone.inCamp.fill(palette), palette.success);
      expect(StateTone.excuse.fill(palette), palette.statusExcuse);
      expect(StateTone.leave.fill(palette), palette.statusLeave);
      expect(StateTone.medical.fill(palette), palette.statusMedical);
      expect(StateTone.out.fill(palette), palette.tickOff);
      expect(StateTone.accent.fill(palette), palette.accent);
    }
  });

  test('no two tones share a fill', () {
    for (final palette in [AppPalette.dark, AppPalette.light]) {
      final fills = {for (final tone in StateTone.values) tone.fill(palette)};
      expect(fills.length, StateTone.values.length);
    }
  });

  test('every parade state maps to the tone of the same name', () {
    expect(ParadeState.inCamp.tone, StateTone.inCamp);
    expect(ParadeState.excuse.tone, StateTone.excuse);
    expect(ParadeState.medical.tone, StateTone.medical);
    expect(ParadeState.leave.tone, StateTone.leave);
    expect(ParadeState.out.tone, StateTone.out);
    expect(ParadeState.values.length, 5);
  });

  test('accent is a participation tone, not a parade state', () {
    final tones = {for (final state in ParadeState.values) state.tone};
    expect(tones, hasLength(ParadeState.values.length));
    expect(tones, isNot(contains(StateTone.accent)));
  });

  test('status tones run from their fill to a darker end', () {
    for (final palette in [AppPalette.dark, AppPalette.light]) {
      for (final tone in [
        StateTone.excuse,
        StateTone.leave,
        StateTone.medical,
      ]) {
        final colors = tone.gradient(palette);
        expect(colors, hasLength(2));
        expect(colors.first, tone.fill(palette));
        expect(colors.last, isNot(colors.first));
        expect(colors.last.computeLuminance(),
            lessThan(colors.first.computeLuminance()));
      }
      expect(StateTone.inCamp.gradient(palette),
          [StateTone.inCamp.fill(palette), StateTone.inCamp.fill(palette)]);
    }
  });

  test('a status takes the tone of its type', () {
    expect(buildStatus(type: StatusTypes.excuse).tone, StateTone.excuse);
    expect(buildStatus(type: StatusTypes.leave).tone, StateTone.leave);
    expect(buildStatus(type: StatusTypes.medicalAppointment).tone,
        StateTone.medical);
  });
}
