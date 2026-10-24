import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/app_segmented_control.dart';

import '../../helpers/pump_app.dart';

enum _Mode { strength, calendar }

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

Future<void> _loadFonts(WidgetTester tester) => tester.runAsync(() async {
      GoogleFonts.barlow(fontWeight: FontWeight.w600);
      GoogleFonts.barlowCondensed(fontWeight: FontWeight.w600);
      await GoogleFonts.pendingFonts();
    });

const _segments = [
  AppSegment(value: _Mode.strength, label: 'Strength'),
  AppSegment(value: _Mode.calendar, label: 'Calendar'),
];

Future<void> _pump(
  WidgetTester tester, {
  List<AppSegment<_Mode>> segments = _segments,
  _Mode selected = _Mode.strength,
  ValueChanged<_Mode>? onChanged,
  bool glass = false,
  ThemeMode mode = ThemeMode.dark,
  double width = 358,
}) async {
  await _loadFonts(tester);
  await tester.pumpThemed(
    Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        child: AppSegmentedControl<_Mode>(
          segments: segments,
          selected: selected,
          onChanged: onChanged ?? (_) {},
          glass: glass,
        ),
      ),
    ),
    mode: mode,
  );
}

Finder _segment(_Mode mode) => find.byKey(ValueKey('segment-${mode.name}'));

BoxDecoration _track(WidgetTester tester) => tester
    .widget<DecoratedBox>(find
        .descendant(
            of: find.byType(AppSegmentedControl<_Mode>),
            matching: find.byType(DecoratedBox))
        .first)
    .decoration as BoxDecoration;

BoxDecoration _fill(WidgetTester tester, _Mode mode) => tester
    .widget<AnimatedContainer>(find.descendant(
        of: _segment(mode), matching: find.byType(AnimatedContainer)))
    .decoration! as BoxDecoration;

Color _labelColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!.color!;

void main() {
  group('layout', () {
    testWidgets('is a 38 px segment inside a 3 px frame, 13 px radius',
        (tester) async {
      await _pump(tester);
      expect(tester.getSize(find.byType(AppSegmentedControl<_Mode>)).height,
          38 + 2 * 3);
      expect(tester.getSize(_segment(_Mode.strength)).height, 38);
      expect(_track(tester).borderRadius, BorderRadius.circular(13));
      expect(
        (_fill(tester, _Mode.strength).borderRadius! as BorderRadius).topLeft,
        const Radius.circular(10),
      );
    });

    testWidgets('segments share the width equally, 2 px apart', (tester) async {
      await _pump(tester);
      final first = tester.getRect(_segment(_Mode.strength));
      final second = tester.getRect(_segment(_Mode.calendar));
      expect(first.width, second.width);
      expect(second.left - first.right, 2);
      expect(first.left, 3);
      expect(second.right, 358 - 3);
    });

    testWidgets('a label too long for its segment ellipsizes, not overflows',
        (tester) async {
      await _pump(
        tester,
        width: 160,
        segments: const [
          AppSegment(value: _Mode.strength, label: 'Participants', count: 27),
          AppSegment(
              value: _Mode.calendar, label: 'Non-Participants', count: 15),
        ],
      );
      expect(tester.takeException(), isNull);
      expect(tester.widget<Text>(find.text('Non-Participants')).overflow,
          TextOverflow.ellipsis);
    });
  });

  group('content', () {
    testWidgets('shows an icon and a count in the figure font', (tester) async {
      await _pump(tester, segments: const [
        AppSegment(
          value: _Mode.strength,
          label: 'Strength',
          icon: Icons.groups_rounded,
          count: 27,
        ),
        AppSegment(value: _Mode.calendar, label: 'Calendar'),
      ]);
      final icon = tester.widget<Icon>(find.byIcon(Icons.groups_rounded));
      expect(icon.size, 20);
      final count = tester.widget<Text>(find.text('27'));
      expect(count.style!.fontFamily, startsWith('BarlowCondensed'));
      expect(count.style!.fontSize, 14.5);
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('label is Barlow 14.5 w600', (tester) async {
      await _pump(tester);
      final style = tester.widget<Text>(find.text('Strength')).style!;
      expect([style.fontSize, style.fontWeight], [14.5, FontWeight.w600]);
      expect(style.fontFamily, startsWith('Barlow'));
    });

    testWidgets('default keys use the enum name; an explicit key wins',
        (tester) async {
      const custom = Key('showCalendar');
      await _pump(tester, segments: const [
        AppSegment(value: _Mode.strength, label: 'Strength'),
        AppSegment(value: _Mode.calendar, label: 'Calendar', key: custom),
      ]);
      expect(_segment(_Mode.strength), findsOneWidget);
      expect(_segment(_Mode.calendar), findsNothing);
      expect(find.byKey(custom), findsOneWidget);
    });
  });

  group('selection', () {
    testWidgets('tapping another segment reports its value', (tester) async {
      final changes = <_Mode>[];
      await _pump(tester, onChanged: changes.add);
      await tester.tap(_segment(_Mode.calendar));
      expect(changes, [_Mode.calendar]);
    });

    testWidgets('tapping the selected segment reports nothing', (tester) async {
      final changes = <_Mode>[];
      await _pump(tester, onChanged: changes.add);
      await tester.tap(_segment(_Mode.strength));
      expect(changes, isEmpty);
    });

    testWidgets('the selected segment is a selected button in semantics',
        (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester);
      expect(
        tester.getSemantics(_segment(_Mode.strength)),
        isSemantics(isButton: true, isSelected: true, hasTapAction: true),
      );
      expect(
        tester.getSemantics(_segment(_Mode.calendar)),
        isSemantics(isButton: true, isSelected: false, hasTapAction: true),
      );
      handle.dispose();
    });

    testWidgets('moving the selection moves the fill and the label colours',
        (tester) async {
      final palette = AppPalette.dark;
      await _pump(tester);
      expect(_fill(tester, _Mode.strength).color, palette.card);
      expect(_fill(tester, _Mode.calendar).color, Colors.transparent);

      await _pump(tester, selected: _Mode.calendar);
      await tester.pumpAndSettle();
      expect(_fill(tester, _Mode.strength).color, Colors.transparent);
      expect(_fill(tester, _Mode.calendar).color, palette.card);
      expect(_labelColor(tester, 'Calendar'), palette.onCard);
      expect(_labelColor(tester, 'Strength'), palette.secondaryText);
    });
  });

  group('look', () {
    testWidgets('normal: card2 track, card fill, on-card and secondary text',
        (tester) async {
      final mode = themeModes.currentValue!;
      final palette = _paletteOf(mode);
      await _pump(tester, mode: mode);
      expect(_track(tester).color, palette.cardElevated);
      expect(_fill(tester, _Mode.strength).color, palette.card);
      expect(_labelColor(tester, 'Strength'), palette.onCard);
      expect(_labelColor(tester, 'Calendar'), palette.secondaryText);
      expect(_fill(tester, _Mode.strength).boxShadow, isNotEmpty);
      expect(_fill(tester, _Mode.calendar).boxShadow, isNull);
    }, variant: themeModes);

    testWidgets('glass: translucent track, white fill, dark violet text',
        (tester) async {
      await _pump(tester, glass: true, mode: themeModes.currentValue!);
      expect(_track(tester).color, AppColors.onGradientTrack);
      expect(_fill(tester, _Mode.strength).color, AppColors.white);
      expect(_labelColor(tester, 'Strength'), AppColors.onGradientSolidText);
      expect(_labelColor(tester, 'Calendar'), AppColors.onGradientLabel);
    }, variant: themeModes);

    testWidgets('glass looks the same in both themes', (tester) async {
      final looks = <Color?>[];
      for (final mode in ThemeMode.values.where((m) => m != ThemeMode.system)) {
        await _pump(tester, glass: true, mode: mode);
        looks.add(_track(tester).color);
      }
      expect(looks.toSet(), hasLength(1));
    });
  });
}
