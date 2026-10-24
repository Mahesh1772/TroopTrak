import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/fraction_bar.dart';
import 'package:trooptrak_final_application/core/widgets/hero_dialog_route.dart';
import 'package:trooptrak_final_application/core/widgets/hero_sheet.dart';

import '../../helpers/pump_app.dart';

Future<void> _open(
  WidgetTester tester, {
  required Widget content,
  ThemeMode mode = ThemeMode.dark,
}) async {
  await tester.pumpThemed(
    Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.of(context).push(HeroDialogRoute<void>(
          builder: (_) => HeroSheet(tag: 'sheet', child: content),
        )),
        child: const Text('open'),
      ),
    ),
    mode: mode,
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('HeroSheet', () {
    testWidgets('sits on the bottom edge, full width, on the sheet colour',
        (tester) async {
      final mode = themeModes.currentValue!;
      await _open(tester,
          content: const SizedBox(key: Key('content'), height: 100),
          mode: mode);
      final sheet = find
          .descendant(
              of: find.byType(HeroSheet), matching: find.byType(Material))
          .first;
      final material = tester.widget<Material>(sheet);
      expect(material.color,
          (mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light).sheet);
      expect(
        material.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      );
      expect(tester.getBottomLeft(sheet).dy, 844);
      expect(tester.getSize(sheet).width, 390);
      expect(find.byKey(const Key('sheetHandle')), findsOneWidget);
      expect(find.byKey(const Key('content')), findsOneWidget);
    }, variant: themeModes);

    testWidgets('content taller than 90% of the screen scrolls',
        (tester) async {
      await _open(tester,
          content: const SizedBox(key: Key('tall'), height: 2000));
      final sheet = find
          .descendant(
              of: find.byType(HeroSheet), matching: find.byType(Material))
          .first;
      expect(tester.getSize(sheet).height, closeTo(844 * 0.9, 0.01));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('a tap on the scrim closes it', (tester) async {
      await _open(tester, content: const SizedBox(height: 100));
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(HeroSheet), findsNothing);
    });

    testWidgets('the route dims the page with the sheet scrim', (tester) async {
      await _open(tester, content: const SizedBox(height: 100));
      final route = ModalRoute.of(tester.element(find.byType(HeroSheet)))!;
      expect(route.barrierColor, AppColors.scrim);
    });
  });

  group('FractionBar', () {
    Future<void> pumpBar(WidgetTester tester, double fraction,
        {Duration? duration, ThemeMode mode = ThemeMode.dark}) {
      return tester.pumpThemed(
        Center(
          child: SizedBox(
            width: 200,
            child: FractionBar(
              fillKey: const Key('fill'),
              fraction: fraction,
              height: 6,
              duration: duration,
            ),
          ),
        ),
        mode: mode,
      );
    }

    testWidgets('fills a share of the track on the accent colour',
        (tester) async {
      final mode = themeModes.currentValue!;
      await pumpBar(tester, 0.25, mode: mode);
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      expect(tester.getSize(find.byKey(const Key('fill'))), const Size(50, 6));
      final fill = tester.widget<DecoratedBox>(find
          .descendant(
              of: find.byKey(const Key('fill')),
              matching: find.byType(DecoratedBox))
          .first);
      expect((fill.decoration as BoxDecoration).color, palette.accent);
      final track = tester.widget<DecoratedBox>(find
          .ancestor(
              of: find.byKey(const Key('fill')),
              matching: find.byType(DecoratedBox))
          .first);
      expect((track.decoration as BoxDecoration).color, palette.tickOff);
    }, variant: themeModes);

    testWidgets('clamps to the track', (tester) async {
      await pumpBar(tester, 1.7);
      expect(tester.getSize(find.byKey(const Key('fill'))).width, 200);
      await pumpBar(tester, -0.3);
      expect(tester.getSize(find.byKey(const Key('fill'))).width, 0);
    });

    testWidgets('glides to a new fraction when given a duration',
        (tester) async {
      await pumpBar(tester, 1, duration: const Duration(seconds: 1));
      await pumpBar(tester, 0.5, duration: const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 500));
      final mid = tester.getSize(find.byKey(const Key('fill'))).width;
      expect(mid, inExclusiveRange(100, 200));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.getSize(find.byKey(const Key('fill'))).width, 100);
    });
  });
}
