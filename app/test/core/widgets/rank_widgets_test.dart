import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/constants/rank_assets.dart';
import 'package:trooptrak_final_application/core/constants/ranks.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/theme/app_radii.dart';
import 'package:trooptrak_final_application/core/widgets/rank_chip.dart';
import 'package:trooptrak_final_application/core/widgets/rank_plate.dart';

import '../../helpers/pump_app.dart';

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

const _plateKey = Key('plate');

Color _plateColor(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(find
      .descendant(
          of: find.byKey(_plateKey), matching: find.byType(DecoratedBox))
      .first);
  return (box.decoration as BoxDecoration).color!;
}

BoxDecoration _chipDecoration(WidgetTester tester) => tester
    .widget<DecoratedBox>(find
        .descendant(
            of: find.byType(RankChip), matching: find.byType(DecoratedBox))
        .first)
    .decoration as BoxDecoration;

void main() {
  group('RankPlate', () {
    testWidgets('a rank outside the WO group sits on the light plate',
        (tester) async {
      final palette = _paletteOf(themeModes.currentValue!);
      for (final rank in ['REC', 'CFC', 'SCT', '3SG', 'MSG', 'OCT', '2LT']) {
        await tester.pumpThemed(RankPlate(rank, key: _plateKey),
            mode: themeModes.currentValue!);
        expect(_plateColor(tester), palette.rankPlate, reason: rank);
      }
    }, variant: themeModes);

    testWidgets('the WO group sits on the dark plate', (tester) async {
      final palette = _paletteOf(themeModes.currentValue!);
      for (final rank in Ranks.warrantOfficers) {
        await tester.pumpThemed(RankPlate(rank, key: _plateKey),
            mode: themeModes.currentValue!);
        expect(_plateColor(tester), palette.rankPlateDark, reason: rank);
      }
    }, variant: themeModes);

    testWidgets('the plate colour follows RankAssets.paleInsignia',
        (tester) async {
      for (final rank in Ranks.all) {
        await tester.pumpThemed(RankPlate(rank, key: _plateKey));
        expect(
            _plateColor(tester),
            RankAssets.paleInsignia(rank)
                ? AppPalette.dark.rankPlateDark
                : AppPalette.dark.rankPlate,
            reason: rank);
      }
    });

    testWidgets('shows the lowercase rank asset untinted', (tester) async {
      await tester.pumpThemed(const RankPlate('3SG', key: _plateKey));
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName,
          'lib/assets/army-ranks/3sg.png');
      expect(image.color, isNull);
      expect(image.semanticLabel, '3SG insignia');
    });

    testWidgets('sizes: 32, 40 and 64 with the mockup radius and inset',
        (tester) async {
      for (final (size, radius, inner) in [
        (RankPlate.sm, 8.0, 24.32),
        (RankPlate.md, 10.0, 30.4),
        (RankPlate.lg, 16.0, 48.64),
      ]) {
        await tester.pumpThemed(Center(
          child: RankPlate('CPL', key: _plateKey, size: size),
        ));
        expect(tester.getSize(find.byKey(_plateKey)), Size.square(size));
        final box = tester.widget<DecoratedBox>(find
            .descendant(
                of: find.byKey(_plateKey), matching: find.byType(DecoratedBox))
            .first);
        expect((box.decoration as BoxDecoration).borderRadius,
            BorderRadius.circular(radius));
        expect(tester.getSize(find.byType(Image)), Size.square(inner));
      }
      expect(RankPlate.sm, 32);
      expect(RankPlate.md, 40);
      expect(RankPlate.lg, 64);
    });

    testWidgets('defaults to the 40 px plate', (tester) async {
      await tester
          .pumpThemed(const Center(child: RankPlate('CPL', key: _plateKey)));
      expect(tester.getSize(find.byKey(_plateKey)), const Size.square(40));
    });

    testWidgets('an unknown rank falls back to an icon in a contrasting tone',
        (tester) async {
      await tester.pumpThemed(const RankPlate('XYZ', key: _plateKey));
      await tester.pumpAndSettle();
      final icon =
          tester.widget<Icon>(find.byIcon(Icons.military_tech_rounded));
      expect(icon.color, AppPalette.dark.rankPlateDark);
      expect(_plateColor(tester), AppPalette.dark.rankPlate);
    });
  });

  group('RankChip', () {
    testWidgets('shows the rank letters on the colour of its group',
        (tester) async {
      for (final rank in Ranks.all) {
        await tester.pumpThemed(RankChip(rank));
        expect(find.text(rank), findsOneWidget);
        expect(_chipDecoration(tester).color,
            AppColors.rankTile(Ranks.groupOf(rank)),
            reason: rank);
      }
    });

    testWidgets('has one colour per rank group', (tester) async {
      final seen = <RankGroup, Color>{};
      for (final rank in Ranks.all) {
        await tester.pumpThemed(RankChip(rank));
        seen[Ranks.groupOf(rank)] = _chipDecoration(tester).color!;
      }
      expect(seen.keys.toSet(), {
        for (final group in RankGroup.values)
          if (group != RankGroup.unknown) group,
      });
      expect(seen.values.toSet(), hasLength(seen.length));
    });

    testWidgets('is white condensed text with a 5 px radius', (tester) async {
      await tester.pumpThemed(const RankChip('CPT'));
      final style = tester.widget<Text>(find.text('CPT')).style!;
      expect(style.color, AppColors.white);
      expect(style.fontSize, 12.5);
      expect(style.fontFamily, 'BarlowCondensed_600');
      expect(style.letterSpacing, closeTo(12.5 * 0.05, 1e-9));
      expect(_chipDecoration(tester).borderRadius,
          BorderRadius.circular(AppRadii.xs));
    });

    testWidgets('is the same in both themes and as tall as its text plus 6 px',
        (tester) async {
      await tester.pumpThemed(const Center(child: RankChip('LTA')),
          mode: themeModes.currentValue!);
      expect(_chipDecoration(tester).color, AppColors.rankJuniorOfficer);
      expect(tester.getSize(find.byType(RankChip)).height, closeTo(18.5, 0.6));
    }, variant: themeModes);

    testWidgets('an unknown rank still draws a chip', (tester) async {
      await tester.pumpThemed(const RankChip('XYZ'));
      expect(find.text('XYZ'), findsOneWidget);
      expect(_chipDecoration(tester).color, AppColors.rankSeniorOfficer);
    });
  });
}
