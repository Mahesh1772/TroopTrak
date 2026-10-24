import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/state_chip.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_state.dart';

import '../../helpers/pump_app.dart';

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

Color _background(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(find
      .descendant(
          of: find.byType(StateChip), matching: find.byType(DecoratedBox))
      .first);
  return (box.decoration as ShapeDecoration).color!;
}

void main() {
  group('StateTone text and tint', () {
    test('text uses the legible tint of each tone in both themes', () {
      for (final palette in [AppPalette.dark, AppPalette.light]) {
        expect(StateTone.inCamp.text(palette), palette.successText);
        expect(StateTone.excuse.text(palette), palette.excuseText);
        expect(StateTone.leave.text(palette), palette.leaveText);
        expect(StateTone.medical.text(palette), palette.medicalText);
        expect(StateTone.out.text(palette), palette.secondaryText);
        expect(StateTone.accent.text(palette), palette.accentText);
      }
    });

    test('tint is 16 percent of the fill, 18 for medical and accent', () {
      for (final palette in [AppPalette.dark, AppPalette.light]) {
        for (final tone in [
          StateTone.inCamp,
          StateTone.excuse,
          StateTone.leave,
        ]) {
          expect(tone.tint(palette), tone.fill(palette).withValues(alpha: .16));
        }
        for (final tone in [StateTone.medical, StateTone.accent]) {
          expect(tone.tint(palette), tone.fill(palette).withValues(alpha: .18));
        }
        expect(StateTone.out.tint(palette), palette.hover);
      }
    });

    test('every tone has a distinct tint', () {
      for (final palette in [AppPalette.dark, AppPalette.light]) {
        final tints = {for (final tone in StateTone.values) tone.tint(palette)};
        expect(tints.length, StateTone.values.length);
      }
    });
  });

  group('StateChip', () {
    testWidgets('shows its label in the text colour on the tint',
        (tester) async {
      final palette = _paletteOf(themeModes.currentValue!);
      for (final tone in StateTone.values) {
        await tester.pumpThemed(StateChip('Label ${tone.name}', tone: tone),
            mode: themeModes.currentValue!);
        final text = tester.widget<Text>(find.text('Label ${tone.name}'));
        expect(text.style!.color, tone.text(palette), reason: tone.name);
        expect(text.style!.fontSize, 12.5);
        expect(_background(tester), tone.tint(palette), reason: tone.name);
      }
    }, variant: themeModes);

    testWidgets('each parade state maps to its own chip colours',
        (tester) async {
      final seen = <Color>{};
      for (final state in ParadeState.values) {
        await tester.pumpThemed(StateChip(state.name, tone: state.tone));
        seen.add(_background(tester));
      }
      expect(seen, hasLength(ParadeState.values.length));
    });

    testWidgets('is a 22 px pill that hugs its content', (tester) async {
      await tester.pumpThemed(const Align(
        alignment: Alignment.topLeft,
        child: StateChip('Annual Leave', tone: StateTone.leave),
      ));
      final size = tester.getSize(find.byType(StateChip));
      expect(size.height, 22);
      expect(size.width, lessThan(150));
      final box = tester.widget<DecoratedBox>(find
          .descendant(
              of: find.byType(StateChip), matching: find.byType(DecoratedBox))
          .first);
      expect((box.decoration as ShapeDecoration).shape, isA<StadiumBorder>());
    });

    testWidgets('draws an optional leading icon in the text colour',
        (tester) async {
      await tester.pumpThemed(const StateChip('On duty',
          tone: StateTone.inCamp, icon: Icons.check_rounded));
      final icon = tester.widget<Icon>(find.byIcon(Icons.check_rounded));
      expect(icon.color, AppPalette.dark.successText);
      expect(icon.size, 18);
    });

    testWidgets('has no icon unless asked for', (tester) async {
      await tester.pumpThemed(const StateChip('You', tone: StateTone.accent));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('a long label ellipsizes inside a narrow slot', (tester) async {
      await tester.pumpThemed(const Center(
        child: SizedBox(
          width: 80,
          child: StateChip('Medical Appointment follow up',
              tone: StateTone.medical),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(
          tester.getSize(find.byType(StateChip)).width, lessThanOrEqualTo(80));
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });
  });
}
