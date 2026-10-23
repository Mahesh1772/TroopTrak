import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/primary_button.dart';

import '../../helpers/pump_app.dart';

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

Future<void> _pump(
  WidgetTester tester, {
  PrimaryButtonStyle style = PrimaryButtonStyle.primary,
  VoidCallback? onPressed,
  IconData? icon,
  bool compact = false,
  bool expand = true,
  bool loading = false,
  ThemeMode mode = ThemeMode.dark,
}) =>
    tester.pumpThemed(
      Align(
        alignment: Alignment.topLeft,
        child: PrimaryButton(
          key: const Key('button'),
          label: 'Save',
          icon: icon,
          style: style,
          compact: compact,
          expand: expand,
          loading: loading,
          onPressed: onPressed,
        ),
      ),
      mode: mode,
    );

ShapeDecoration _decoration(WidgetTester tester) => tester
    .widget<DecoratedBox>(find
        .descendant(
            of: find.byKey(const Key('button')),
            matching: find.byType(DecoratedBox))
        .first)
    .decoration as ShapeDecoration;

BorderSide _outline(WidgetTester tester) =>
    (_decoration(tester).shape as StadiumBorder).side;

TextStyle _labelStyle(WidgetTester tester) =>
    tester.widget<Text>(find.text('Save')).style!;

void main() {
  group('primary', () {
    testWidgets('is a 50 px pill on the button gradient with a soft shadow',
        (tester) async {
      final mode = themeModes.currentValue!;
      await _pump(tester, onPressed: () {}, mode: mode);
      final decoration = _decoration(tester);
      final gradient = decoration.gradient! as LinearGradient;

      expect(
          tester.getSize(find.byKey(const Key('button'))), const Size(390, 50));
      expect(decoration.shape, isA<StadiumBorder>());
      expect(gradient.colors, _paletteOf(mode).buttonGradient);
      expect(gradient.begin, Alignment.topLeft);
      expect(gradient.end, Alignment.bottomRight);
      expect(decoration.shadows, hasLength(1));
      expect(decoration.shadows!.single.offset, const Offset(0, 8));
      expect(decoration.shadows!.single.color.a, closeTo(0.9, 0.01));
    }, variant: themeModes);

    testWidgets('label is white Barlow 15 w600 with 0.04em tracking',
        (tester) async {
      await _pump(tester, onPressed: () {});
      final style = _labelStyle(tester);
      expect(style.color, AppColors.white);
      expect(style.fontSize, 15);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.fontFamily, startsWith('Barlow'));
      expect(style.letterSpacing, closeTo(0.6, 0.001));
    });

    testWidgets('an icon sits 8 px before the label at 20 px', (tester) async {
      await _pump(tester, onPressed: () {}, icon: Icons.add_rounded);
      final icon = find.byIcon(Icons.add_rounded);
      expect(tester.widget<Icon>(icon).size, 20);
      expect(tester.widget<Icon>(icon).color, AppColors.white);
      expect(
        tester.getTopLeft(find.text('Save')).dx - tester.getTopRight(icon).dx,
        8,
      );
    });
  });

  group('ghost', () {
    testWidgets('is an unfilled pill with a 1.5 px neutral outline',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pump(tester,
          style: PrimaryButtonStyle.ghost, onPressed: () {}, mode: mode);
      final decoration = _decoration(tester);

      expect(decoration.gradient, isNull);
      expect(decoration.color, isNull);
      expect(decoration.shadows, isNull);
      expect(_outline(tester).width, 1.5);
      expect(_outline(tester).color, isNot(palette.line));
      expect(_labelStyle(tester).color, palette.onCard);
      expect(tester.getSize(find.byKey(const Key('button'))).height, 50);
    }, variant: themeModes);
  });

  group('danger', () {
    testWidgets('is a red outline pill with legible red text', (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pump(tester,
          style: PrimaryButtonStyle.danger, onPressed: () {}, mode: mode);

      expect(_decoration(tester).gradient, isNull);
      expect(_outline(tester).width, 1.5);
      expect(_outline(tester).color.toARGB32() & 0xFFFFFF,
          palette.danger.toARGB32() & 0xFFFFFF);
      expect(_outline(tester).color.a, closeTo(0.55, 0.01));
      expect(_labelStyle(tester).color, palette.leaveText);
    }, variant: themeModes);
  });

  group('tonal', () {
    testWidgets('is a 40 px accent tint that wraps its content',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pump(tester,
          style: PrimaryButtonStyle.tonal,
          icon: Icons.add_rounded,
          onPressed: () {},
          mode: mode);
      final size = tester.getSize(find.byKey(const Key('button')));

      expect(size.height, 40);
      expect(size.width, lessThan(200));
      expect(_decoration(tester).color, palette.accent.withValues(alpha: 0.22));
      expect(_decoration(tester).gradient, isNull);
      expect(_labelStyle(tester).color, palette.accentText);
      expect(_labelStyle(tester).fontSize, 14.5);
    }, variant: themeModes);

    testWidgets('pads 12 before an icon and 16 after the label',
        (tester) async {
      await _pump(tester,
          style: PrimaryButtonStyle.tonal,
          icon: Icons.add_rounded,
          onPressed: () {});
      final box = tester.getRect(find.byKey(const Key('button')));
      expect(
          tester.getTopLeft(find.byIcon(Icons.add_rounded)).dx - box.left, 12);
      expect(box.right - tester.getTopRight(find.text('Save')).dx, 16);
    });

    testWidgets('pads 16 on both sides without an icon', (tester) async {
      await _pump(tester, style: PrimaryButtonStyle.tonal, onPressed: () {});
      final box = tester.getRect(find.byKey(const Key('button')));
      expect(tester.getTopLeft(find.text('Save')).dx - box.left, 16);
    });
  });

  group('size', () {
    testWidgets('compact is 36 px with a 13 px label', (tester) async {
      await _pump(tester, compact: true, onPressed: () {});
      expect(tester.getSize(find.byKey(const Key('button'))).height, 36);
      expect(_labelStyle(tester).fontSize, 13);
    });

    testWidgets('expand false wraps the content', (tester) async {
      await _pump(tester, expand: false, onPressed: () {});
      expect(
          tester.getSize(find.byKey(const Key('button'))).width, lessThan(200));
    });

    testWidgets('a long label is cut on one line', (tester) async {
      await tester.pumpThemed(
        const SizedBox(
          width: 120,
          child: PrimaryButton(
            label: 'A very long button label that cannot fit',
            onPressed: null,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(find.byType(Text));
      expect([text.maxLines, text.overflow], [1, TextOverflow.ellipsis]);
    });
  });

  group('behaviour', () {
    testWidgets('fires onPressed in either theme', (tester) async {
      var taps = 0;
      await _pump(tester,
          onPressed: () => taps++, mode: themeModes.currentValue!);
      await tester.tap(find.text('Save'));
      expect(taps, 1);
    }, variant: themeModes);

    testWidgets('a null onPressed fades to 40 percent and ignores taps',
        (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Save'));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.4);
    });

    testWidgets('loading keeps full opacity, shows a spinner and ignores taps',
        (tester) async {
      var taps = 0;
      await _pump(tester, loading: true, onPressed: () => taps++);
      await tester.tap(find.byKey(const Key('button')));

      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    });
  });
}
