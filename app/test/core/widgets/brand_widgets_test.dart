import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/brand_mascot.dart';
import 'package:trooptrak_final_application/core/widgets/brand_plate.dart';
import 'package:trooptrak_final_application/core/widgets/page_back_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('BrandMascot', () {
    testWidgets('is tinted with the accent text colour at the given height',
        (tester) async {
      final mode = themeModes.currentValue!;
      await tester.pumpThemed(const BrandMascot(height: 132), mode: mode);
      final image = tester.widget<Image>(find.byType(Image));
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      expect(image.color, palette.accentText);
      expect(tester.getSize(find.byType(BrandMascot)).height, 132);
    }, variant: themeModes);
  });

  group('BrandPlate', () {
    testWidgets('is a 64 px plate on the header gradient with a white icon',
        (tester) async {
      final mode = themeModes.currentValue!;
      await tester.pumpThemed(const BrandPlate(Icons.military_tech_rounded),
          mode: mode);
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      expect(tester.getSize(find.byType(BrandPlate)), const Size.square(64));
      final decoration = tester
          .widget<DecoratedBox>(find.descendant(
              of: find.byType(BrandPlate), matching: find.byType(DecoratedBox)))
          .decoration as BoxDecoration;
      expect((decoration.gradient as LinearGradient).colors,
          palette.headerGradient);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      final icon =
          tester.widget<Icon>(find.byIcon(Icons.military_tech_rounded));
      expect(icon.size, 36);
      expect(icon.color, AppColors.white);
    }, variant: themeModes);
  });

  group('PageBackButton', () {
    testWidgets('pops the page and sits 12 px left of the page inset',
        (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  body: Padding(
                    padding: EdgeInsets.all(24),
                    child: PageBackButton(),
                  ),
                ),
              )),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final button = tester.getRect(find.byType(IconButton));
      expect(button.size, const Size.square(44));
      expect(button.left, 12);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(find.byType(PageBackButton), findsNothing);
    });

    testWidgets('draws the arrow in the theme text colour', (tester) async {
      final mode = themeModes.currentValue!;
      await tester.pumpThemed(const PageBackButton(), mode: mode);
      final theme = Theme.of(tester.element(find.byType(PageBackButton)));
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(tester.widget<IconButton>(find.byType(IconButton)).color,
          theme.colorScheme.onSurface);
    }, variant: themeModes);
  });
}
