import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trooptrak_final_application/core/constants/ranks.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_layout.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/theme/app_radii.dart';
import 'package:trooptrak_final_application/core/theme/app_tab_indicator.dart';
import 'package:trooptrak_final_application/core/theme/app_text_styles.dart';
import 'package:trooptrak_final_application/core/theme/dark_theme.dart';
import 'package:trooptrak_final_application/core/theme/light_theme.dart';
import 'package:trooptrak_final_application/core/theme/theme_context.dart';

import '../../helpers/pump_app.dart';

Future<ThemeData> _build(
    WidgetTester tester, ThemeData Function() builder) async {
  late ThemeData theme;
  await tester.pumpWidget(ScreenUtilInit(
    designSize: AppLayout.designSize,
    builder: (_, __) {
      theme = builder();
      return MaterialApp(theme: theme, home: const SizedBox.shrink());
    },
  ));
  return theme;
}

AppPalette _paletteOf(ThemeMode mode) =>
    mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

ThemeData _themeOf(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first));

TextStyle _styleAt(WidgetTester tester, Finder finder) =>
    DefaultTextStyle.of(tester.element(finder)).style;

Future<void> _loadBarlow(WidgetTester tester) => tester.runAsync(() async {
      for (final weight in [
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
      ]) {
        GoogleFonts.barlow(fontWeight: weight);
      }
      await GoogleFonts.pendingFonts();
    });

/// Paint stores colour channels as 32-bit floats, so compare the 8-bit value.
Matcher _isColor(Color expected) => predicate<Color>(
      (actual) => actual.toARGB32() == expected.toARGB32(),
      'is $expected',
    );

typedef _Drawn = ({RRect rrect, Paint paint});

/// Every rounded rectangle [object] draws, in paint order.
List<_Drawn> _rrects(RenderObject object) {
  final drawn = <_Drawn>[];
  expect(
    object,
    paints
      ..everything((method, args) {
        if (method == #drawRRect) {
          drawn.add((rrect: args[0] as RRect, paint: args[1] as Paint));
        }
        return true;
      }),
  );
  return drawn;
}

void main() {
  testWidgets('dark theme is built from tokens', (tester) async {
    final theme = await _build(tester, buildDarkTheme);
    final scheme = theme.colorScheme;

    expect(theme.brightness, Brightness.dark);
    expect(scheme.primary, AppColors.darkPrimary);
    expect(scheme.surface, AppColors.darkSurface);
    expect(scheme.secondary, AppColors.brandIndigo);
    expect(scheme.tertiary, AppColors.white);
    expect(scheme.onSurface, AppColors.white);
    expect(scheme.error, AppColors.danger);
    expect(theme.scaffoldBackgroundColor, AppColors.darkSurface);
    expect(theme.appBarTheme.backgroundColor, AppColors.brandIndigo);
    expect(theme.extension<AppPalette>(), AppPalette.dark);
    expect(theme.cardTheme.color, AppColors.darkCard);
    expect(theme.inputDecorationTheme.fillColor, AppColors.darkCardElevated);
  });

  testWidgets('light theme is built from tokens', (tester) async {
    final theme = await _build(tester, buildLightTheme);
    final scheme = theme.colorScheme;

    expect(theme.brightness, Brightness.light);
    expect(scheme.primary, AppColors.lightPrimary);
    expect(scheme.surface, AppColors.lightSurface);
    expect(scheme.secondary, AppColors.brandIndigo);
    expect(scheme.tertiary, AppColors.black);
    expect(scheme.onSurface, AppColors.black);
    expect(theme.appBarTheme.backgroundColor, AppColors.lightPrimary);
    expect(theme.extension<AppPalette>(), AppPalette.light);
    expect(theme.cardTheme.color, AppColors.lightCard);
    expect(theme.inputDecorationTheme.fillColor, AppColors.lightCardElevated);
  });

  test('dark palette carries the mockup tokens', () {
    const palette = AppPalette.dark;
    expect(palette.page, const Color(0xFF0D1016));
    expect(palette.pageLine, const Color(0xFF1C2130));
    expect(palette.navBar, const Color(0xFF202433));
    expect(palette.sheet, const Color(0xFF232837));
    expect(palette.secondaryText, const Color(0xFFB3B8C8));
    expect(palette.mutedText, const Color(0xFF8C92A5));
    expect(palette.line, const Color(0x14FFFFFF));
    expect(palette.tickOff, const Color(0x21FFFFFF));
    expect(palette.tickFuture, const Color(0x0DFFFFFF));
    expect(palette.accentText, const Color(0xFFB196F5));
    expect(palette.successText, const Color(0xFF6CCB70));
    expect(palette.excuseText, const Color(0xFFFF9840));
    expect(palette.leaveText, const Color(0xFFFF7A70));
    expect(palette.medicalText, const Color(0xFF5AA9F0));
    expect(palette.rankPlate, const Color(0xFFE9EBF4));
    expect(palette.rankPlateDark, const Color(0xFF2D3241));
    expect(palette.duty, const Color(0xFFE91E63));
  });

  test('light palette carries the mockup tokens', () {
    const palette = AppPalette.light;
    expect(palette.page, const Color(0xFFE4E8F2));
    expect(palette.pageLine, const Color(0xFFD2D8E6));
    expect(palette.navBar, const Color(0xFFFFFFFF));
    expect(palette.sheet, const Color(0xFFFFFFFF));
    expect(palette.secondaryText, const Color(0xFF4B5168));
    expect(palette.mutedText, const Color(0xFF6E7489));
    expect(palette.line, const Color(0x1412151D));
    expect(palette.hover, const Color(0x0D12151D));
    expect(palette.tickOff, const Color(0xFFDADEEA));
    expect(palette.tickFuture, const Color(0xFFEBEEF6));
    expect(palette.accentText, const Color(0xFF5B2BD0));
    expect(palette.successText, const Color(0xFF2E7D32));
    expect(palette.excuseText, const Color(0xFFC25400));
    expect(palette.leaveText, const Color(0xFFC62828));
    expect(palette.medicalText, const Color(0xFF1565C0));
    expect(palette.rankPlate, const Color(0xFFEDEFF7));
    expect(palette.rankPlateDark, const Color(0xFF2D3241));
    expect(palette.duty, const Color(0xFFE91E63));
  });

  test('copyWith keeps the mockup tokens', () {
    final copy = AppPalette.light.copyWith(card: AppColors.darkCard);
    expect(copy.card, AppColors.darkCard);
    expect(copy.tickOff, AppPalette.light.tickOff);
    expect(copy.accentText, AppPalette.light.accentText);
    expect(copy.rankPlate, AppPalette.light.rankPlate);
    expect(copy.duty, AppPalette.light.duty);
    expect(copy.sheet, AppPalette.light.sheet);
  });

  test('radii follow the mockup scale', () {
    expect(AppRadii.sm, 8);
    expect(AppRadii.lg, 12);
    expect(AppRadii.segmented, 13);
    expect(AppRadii.tile, 16);
    expect(AppRadii.xl, 20);
    expect(AppRadii.sheet, 28);
    expect(AppRadii.pill, 30);
  });

  testWidgets('date and time pickers use the accent colour', (tester) async {
    for (final builder in [buildDarkTheme, buildLightTheme]) {
      final theme = await _build(tester, builder);
      expect(theme.datePickerTheme.headerBackgroundColor, AppColors.accent);
      expect(
        theme.datePickerTheme.dayBackgroundColor
            ?.resolve({WidgetState.selected}),
        AppColors.accent,
      );
      expect(theme.timePickerTheme.dialHandColor, AppColors.accent);
      expect(theme.chipTheme.selectedColor, AppColors.accent);
    }
  });

  testWidgets('text theme uses Barlow at bundled weights', (tester) async {
    final theme = await _build(tester, buildDarkTheme);
    final text = theme.textTheme;
    final styles = [
      text.displayLarge,
      text.displayMedium,
      text.displaySmall,
      text.headlineLarge,
      text.headlineMedium,
      text.headlineSmall,
      text.titleLarge,
      text.titleMedium,
      text.titleSmall,
      text.bodyLarge,
      text.bodyMedium,
      text.bodySmall,
      text.labelLarge,
      text.labelMedium,
      text.labelSmall,
    ];
    for (final style in styles) {
      expect(style?.fontFamily, startsWith('Barlow_'));
      expect(style?.fontFamilyFallback, ['Barlow']);
      expect([400, 500, 600, 700], contains(style?.fontWeight?.value));
    }
    expect(text.headlineLarge?.fontWeight, FontWeight.bold);
  });

  testWidgets('figure style is Barlow Condensed with tabular figures',
      (tester) async {
    useDesignSurface(tester);
    await _build(tester, buildDarkTheme);
    final figure = AppTextStyles.figure(22, FontWeight.w600, AppColors.white);
    expect(figure.fontFamily, 'BarlowCondensed_600');
    expect(figure.fontFamilyFallback, ['BarlowCondensed']);
    expect(figure.fontFeatures, [const FontFeature.tabularFigures()]);
    expect(figure.fontSize, 22);
    expect(figure.color, AppColors.white);
  });

  testWidgets('every bundled Barlow weight loads without runtime fetching',
      (tester) async {
    final manifest = await tester
        .runAsync(() => AssetManifest.loadFromAssetBundle(rootBundle));
    expect(
        manifest!.listAssets(),
        containsAll([
          for (final file in [
            'Barlow-Regular',
            'Barlow-Medium',
            'Barlow-SemiBold',
            'Barlow-Bold',
            'BarlowCondensed-Medium',
            'BarlowCondensed-SemiBold',
            'BarlowCondensed-Bold',
          ])
            'lib/assets/google_fonts/$file.ttf',
          'lib/assets/google_fonts/Barlow-OFL.txt',
        ]));
    await tester.runAsync(() async {
      for (final weight in [
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700
      ]) {
        GoogleFonts.barlow(fontWeight: weight);
        GoogleFonts.barlowCondensed(fontWeight: weight);
      }
      GoogleFonts.barlow(fontWeight: FontWeight.w400);
      await GoogleFonts.pendingFonts();
    });
  });

  testWidgets('design size is the 390x844 mockup phone', (tester) async {
    expect(AppLayout.designSize, const Size(390, 844));
    expect(designSize, AppLayout.designSize);
    await tester.pumpThemed(const SizedBox.shrink());
    expect(ScreenUtil().screenWidth, 390);
    expect(ScreenUtil().screenHeight, 844);
    expect(ScreenUtil().scaleWidth, 1);
    expect(16.sp, 16);
  });

  testWidgets('context extension exposes palette and brightness',
      (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(ScreenUtilInit(
      designSize: AppLayout.designSize,
      builder: (_, __) => MaterialApp(
        theme: buildLightTheme(),
        home: Builder(builder: (context) {
          captured = context;
          return const SizedBox.shrink();
        }),
      ),
    ));
    expect(captured.palette, AppPalette.light);
    expect(captured.isDark, isFalse);
    expect(captured.colors.surface, AppColors.lightSurface);
  });

  testWidgets('NavigationBar is 84 high with a 16 radius indicator',
      (tester) async {
    final mode = themeModes.currentValue!;
    final palette = _paletteOf(mode);
    await tester.pumpThemed(
      Align(
        alignment: Alignment.bottomCenter,
        child: NavigationBar(
          selectedIndex: 0,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.groups_rounded), label: 'Roll'),
          ],
        ),
      ),
      mode: mode,
    );
    final theme = _themeOf(tester);
    final bar = find.byType(NavigationBar);

    expect(tester.getSize(bar).height, 84);
    expect(theme.navigationBarTheme.height, 84);
    expect(
      tester
          .widget<Material>(
              find.descendant(of: bar, matching: find.byType(Material)).first)
          .color,
      palette.navBar,
    );

    final indicator = tester
        .widget<NavigationIndicator>(find.byType(NavigationIndicator).first);
    expect(
      indicator.shape,
      const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
    );
    expect(indicator.color, Colors.transparent);

    final selected = tester.widget<Text>(find.text('Home')).style!;
    final idle = tester.widget<Text>(find.text('Roll')).style!;
    expect([selected.fontSize, idle.fontSize], [12.5, 12.5]);
    expect(selected.fontWeight, FontWeight.w600);
    expect(selected.color, theme.colorScheme.onSurface);
    expect(idle.fontWeight, FontWeight.w500);
    expect(idle.color, palette.secondaryText);

    IconThemeData iconOf(IconData icon) =>
        IconTheme.of(tester.element(find.byIcon(icon)));
    expect(iconOf(Icons.home_rounded).color, AppColors.white);
    expect(iconOf(Icons.groups_rounded).color, palette.secondaryText);
  }, variant: themeModes);

  testWidgets('Switch tracks are tick-off and ok around a white thumb',
      (tester) async {
    final mode = themeModes.currentValue!;
    final palette = _paletteOf(mode);
    await tester.pumpThemed(
      Column(children: [
        Switch(key: const Key('off'), value: false, onChanged: (_) {}),
        Switch(key: const Key('on'), value: true, onChanged: (_) {}),
      ]),
      mode: mode,
    );
    final theme = _themeOf(tester).switchTheme;

    expect(theme.trackColor!.resolve({}), palette.tickOff);
    expect(theme.trackColor!.resolve({WidgetState.selected}), palette.success);
    expect(theme.thumbColor!.resolve({}), AppColors.white);
    expect(theme.thumbColor!.resolve({WidgetState.selected}), AppColors.white);

    final off = _rrects(tester.renderObject(find.byKey(const Key('off'))));
    final on = _rrects(tester.renderObject(find.byKey(const Key('on'))));
    expect(off.first.paint.color, _isColor(palette.tickOff));
    expect(on.first.paint.color, _isColor(palette.success));
    for (final thumb in [off.last, on.last]) {
      expect(thumb.paint.color, _isColor(AppColors.white));
      expect(thumb.rrect.width, thumb.rrect.height);
    }
    expect(off.last.rrect.width, on.last.rrect.width);
    expect(off.last.rrect.height, 24);
  }, variant: themeModes);

  testWidgets('SegmentedButton is a 38 px segment in a 3 px card2 frame',
      (tester) async {
    final mode = themeModes.currentValue!;
    final palette = _paletteOf(mode);
    await tester.pumpThemed(
      SegmentedButton<int>(
        key: const Key('segmented'),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: 0, label: Text('Excuse')),
          ButtonSegment(value: 1, label: Text('Leave')),
          ButtonSegment(value: 2, label: Text('MA')),
        ],
        selected: const {1},
        onSelectionChanged: (_) {},
      ),
      mode: mode,
    );
    final theme = _themeOf(tester);
    final style = theme.segmentedButtonTheme.style!;
    const selected = {WidgetState.selected};

    expect(style.backgroundColor!.resolve(selected), palette.card);
    expect(style.backgroundColor!.resolve({}), palette.cardElevated);
    expect(
        style.foregroundColor!.resolve(selected), theme.colorScheme.onSurface);
    expect(style.foregroundColor!.resolve({}), palette.secondaryText);
    expect(style.side!.resolve({}),
        BorderSide(color: palette.cardElevated, width: 3));
    expect(
      style.shape!.resolve({}),
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    );
    final label = style.textStyle!.resolve({})!;
    expect([label.fontSize, label.fontWeight], [14.5, FontWeight.w600]);

    expect(tester.getSize(find.byKey(const Key('segmented'))).height, 38 + 6);
    expect(_styleAt(tester, find.text('Leave')).color,
        theme.colorScheme.onSurface);
    expect(_styleAt(tester, find.text('Excuse')).color, palette.secondaryText);
  }, variant: themeModes);

  testWidgets('modal bottom sheet has 28 top corners and a 40x4 grab handle',
      (tester) async {
    final mode = themeModes.currentValue!;
    final palette = _paletteOf(mode);
    await tester.pumpThemed(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (_) => const SizedBox(height: 120),
          ),
          child: const Text('open'),
        ),
      ),
      mode: mode,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final sheet = find.byType(BottomSheet);
    final theme = _themeOf(tester).bottomSheetTheme;

    expect(theme.showDragHandle, isTrue);
    expect(theme.dragHandleSize, const Size(40, 4));
    expect(theme.dragHandleColor, palette.tickOff);

    final material = tester.widget<Material>(
        find.descendant(of: sheet, matching: find.byType(Material)).first);
    expect(material.color, palette.sheet);
    expect(
      material.shape,
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );

    final handle =
        find.descendant(of: sheet, matching: find.byType(Container)).first;
    expect(tester.getSize(handle), const Size(40, 4));
    expect((tester.widget<Container>(handle).decoration as BoxDecoration).color,
        palette.tickOff);
  }, variant: themeModes);

  test('sheet surface is card2 in dark and card in light', () {
    expect(AppPalette.dark.sheet, AppPalette.dark.cardElevated);
    expect(AppPalette.light.sheet, AppPalette.light.card);
  });

  testWidgets('TabBar is 50 high with a 3 px accent underline inset 14%',
      (tester) async {
    final mode = themeModes.currentValue!;
    final palette = _paletteOf(mode);
    await _loadBarlow(tester);
    await tester.pumpThemed(
      const DefaultTabController(
        length: 3,
        child: TabBar(tabs: [
          Tab(text: 'INFO'),
          Tab(text: 'STATUSES'),
          Tab(text: 'ATTENDANCE'),
        ]),
      ),
      mode: mode,
    );
    final theme = _themeOf(tester);
    final tabs = theme.tabBarTheme;
    final bar = tester.getSize(find.byType(TabBar));
    final tabWidth = bar.width / 3;

    expect(bar.height, 50);
    expect(
      tabs.indicator,
      AppTabIndicator(color: palette.accent, thickness: 3, insetFraction: 0.14),
    );
    expect(tabs.labelColor, theme.colorScheme.onSurface);
    expect(tabs.unselectedLabelColor, palette.secondaryText);
    expect(tabs.dividerColor, palette.line);
    expect(tabs.labelStyle, tabs.unselectedLabelStyle);
    expect(tabs.labelStyle!.fontSize, 13);
    expect(tabs.labelStyle!.fontWeight, FontWeight.w600);
    expect(tabs.labelStyle!.letterSpacing, moreOrLessEquals(13 * 0.06));

    final underline = _rrects(tester.renderObject(find.byType(TabBar))).single;
    expect(underline.paint.color, _isColor(palette.accent));
    expect(underline.rrect.left, moreOrLessEquals(tabWidth * 0.14));
    expect(underline.rrect.right, moreOrLessEquals(tabWidth * 0.86));
    expect(underline.rrect.height, 3);
    expect(underline.rrect.bottom, bar.height);
    expect(underline.rrect.tlRadius, const Radius.circular(3));
    expect(underline.rrect.trRadius, const Radius.circular(3));
    expect(underline.rrect.blRadius, Radius.zero);
    expect(
      tester.renderObject(find.byType(TabBar)),
      paints..line(color: palette.line, strokeWidth: 1),
    );
  }, variant: themeModes);

  testWidgets('tab labels stay on one line in three tabs and in two',
      (tester) async {
    final mode = themeModes.currentValue!;
    await _loadBarlow(tester);
    for (final labels in [
      ['INFO', 'STATUSES', 'ATTENDANCE'],
      ['LEADERBOARD', 'UPCOMING'],
      ['POINTS LEADERBOARD', 'UPCOMING DUTIES'],
    ]) {
      await tester.pumpThemed(
        DefaultTabController(
          key: ValueKey(labels),
          length: labels.length,
          child: TabBar(tabs: [
            for (final label in labels) Tab(child: Text(label)),
          ]),
        ),
        mode: mode,
      );
      final tabWidth =
          tester.getSize(find.byType(TabBar)).width / labels.length;
      for (final label in labels) {
        final size = tester.getSize(find.text(label));
        expect(size.height, lessThan(13 * 1.5), reason: '$label wrapped');
        expect(size.width, lessThan(tabWidth - 8), reason: '$label is cut');
      }
    }
  }, variant: themeModes);

  testWidgets('an icon beside the label still fits one line in a third tab',
      (tester) async {
    final mode = themeModes.currentValue!;
    await _loadBarlow(tester);
    const labels = ['INFO', 'STATUSES', 'ATTENDANCE'];
    await tester.pumpThemed(
      DefaultTabController(
        length: labels.length,
        child: TabBar(tabs: [
          for (final label in labels)
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.info_rounded, size: 19),
                const SizedBox(width: 6),
                Text(label),
              ]),
            ),
        ]),
      ),
      mode: mode,
    );
    final tabWidth = tester.getSize(find.byType(TabBar)).width / labels.length;
    for (final label in labels) {
      final row =
          find.ancestor(of: find.text(label), matching: find.byType(Row));
      expect(tester.getSize(row.first).width, lessThanOrEqualTo(tabWidth - 8),
          reason: '$label does not fit with the 4 px side padding');
      expect(tester.getSize(find.text(label)).height, lessThan(13 * 1.5));
    }
    expect(tester.takeException(), isNull);
  }, variant: themeModes);

  test('AppTabIndicator compares by colour, thickness and inset', () {
    const base = AppTabIndicator(
        color: AppColors.accent, thickness: 3, insetFraction: .14);
    const same = AppTabIndicator(
        color: AppColors.accent, thickness: 3, insetFraction: .14);
    expect(base, same);
    expect(base.hashCode, same.hashCode);
    expect(
        base,
        isNot(const AppTabIndicator(
            color: AppColors.accent, thickness: 3, insetFraction: .2)));
  });

  testWidgets('text field is 52 high with a 1 px line border and 16 px text',
      (tester) async {
    final mode = themeModes.currentValue!;
    final palette = _paletteOf(mode);
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpThemed(
      Column(children: [
        TextField(
          key: const Key('field'),
          focusNode: focus,
          decoration: const InputDecoration(hintText: 'Search'),
        ),
        const TextField(
          key: Key('invalid'),
          decoration: InputDecoration(hintText: 'Email', errorText: 'Bad'),
        ),
      ]),
      mode: mode,
    );
    final theme = _themeOf(tester);
    final decoration = theme.inputDecorationTheme;
    final field = find.descendant(
        of: find.byKey(const Key('field')),
        matching: find.byType(InputDecorator));
    final invalid = find.descendant(
        of: find.byKey(const Key('invalid')),
        matching: find.byType(InputDecorator));

    expect(decoration.filled, isTrue);
    expect(decoration.fillColor, palette.cardElevated);
    expect(tester.getSize(find.byKey(const Key('field'))).height, 52);
    expect(theme.textTheme.bodyLarge!.fontSize, 16);
    expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .style
            .fontSize,
        16);
    expect(tester.widget<Text>(find.text('Search')).style!.color,
        palette.mutedText);
    expect(decoration.prefixIconColor, palette.secondaryText);
    expect(decoration.errorStyle!.color, palette.leaveText);
    expect(theme.textSelectionTheme.cursorColor, palette.accentText);

    var drawn = _rrects(tester.renderObject(field));
    expect(drawn.first.paint.color, _isColor(palette.cardElevated));
    expect(drawn.first.rrect.tlRadiusX, 12);
    expect(drawn.last.paint.style, PaintingStyle.stroke);
    expect(drawn.last.paint.strokeWidth, 1);
    expect(drawn.last.paint.color, _isColor(palette.line));
    expect(drawn.last.rrect.left, 0.5);

    focus.requestFocus();
    await tester.pumpAndSettle();
    drawn = _rrects(tester.renderObject(field));
    expect(tester.getSize(find.byKey(const Key('field'))).height, 52);
    expect(drawn.last.paint.strokeWidth, 2);
    expect(drawn.last.paint.color, _isColor(palette.accent));
    expect(drawn.last.rrect.left, 1);
    expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .cursorColor,
        palette.accentText);

    drawn = _rrects(tester.renderObject(invalid));
    expect(drawn.last.paint.strokeWidth, 2);
    expect(drawn.last.paint.color, _isColor(palette.danger));
    expect(drawn.last.rrect.tlRadiusX, 11);
    expect(decoration.focusedErrorBorder, decoration.errorBorder);
  }, variant: themeModes);

  testWidgets('chip is 34 high: line border at rest, accent fill when selected',
      (tester) async {
    final mode = themeModes.currentValue!;
    final palette = _paletteOf(mode);
    await tester.pumpThemed(
      Row(children: [
        ChoiceChip(
            key: const Key('rest'),
            label: const Text('Name'),
            selected: false,
            onSelected: (_) {}),
        ChoiceChip(
            key: const Key('picked'),
            label: const Text('Rank'),
            selected: true,
            onSelected: (_) {}),
      ]),
      mode: mode,
    );
    await tester.pumpAndSettle();
    final theme = _themeOf(tester);

    Finder inkOf(String key) =>
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(Ink));
    ShapeDecoration bodyOf(String key) =>
        tester.widget<Ink>(inkOf(key)).decoration! as ShapeDecoration;

    expect(tester.getSize(inkOf('rest')).height, 34);
    expect(tester.getSize(inkOf('picked')).height, 34);
    expect(bodyOf('rest').color, palette.cardElevated);
    expect(bodyOf('rest').shape,
        StadiumBorder(side: BorderSide(color: palette.line)));
    expect(bodyOf('picked').color, palette.accent);
    expect(bodyOf('picked').shape,
        const StadiumBorder(side: BorderSide(color: Colors.transparent)));

    final rest = _styleAt(tester, find.text('Name'));
    final picked = _styleAt(tester, find.text('Rank'));
    expect([rest.fontSize, rest.fontWeight], [14.5, FontWeight.w500]);
    expect(rest.color, theme.colorScheme.onSurface);
    expect(picked.color, AppColors.white);
    expect(theme.chipTheme.showCheckmark, isFalse);
    expect(theme.chipTheme.selectedColor, palette.accent);
  }, variant: themeModes);

  testWidgets('FAB is 60x60 with a 20 radius, a white 28 icon and no gradient',
      (tester) async {
    final mode = themeModes.currentValue!;
    final palette = _paletteOf(mode);
    await tester.pumpThemed(
      Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          key: const Key('fab'),
          heroTag: null,
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
      mode: mode,
    );
    final fab = find.byKey(const Key('fab'));
    final theme = _themeOf(tester).floatingActionButtonTheme;
    final material = tester.widget<Material>(
        find.descendant(of: fab, matching: find.byType(Material)).first);
    final icon = IconTheme.of(tester.element(find.byIcon(Icons.add)));

    expect(tester.getSize(fab), const Size(60, 60));
    expect(
      theme.shape,
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
    expect(material.shape, theme.shape);
    expect(material.color, palette.buttonGradient.last);
    expect(icon.color, AppColors.white);
    expect(icon.size, 28);
  }, variant: themeModes);

  test('rank tile colours follow the source rank bands', () {
    expect(AppColors.rankTile(Ranks.groupOf('PTE')), AppColors.rankEnlisted);
    expect(AppColors.rankTile(Ranks.groupOf('SCT')),
        AppColors.rankSpecialistCadet);
    expect(AppColors.rankTile(Ranks.groupOf('2SG')), AppColors.rankSpecialist);
    expect(
        AppColors.rankTile(Ranks.groupOf('1WO')), AppColors.rankWarrantOfficer);
    expect(
        AppColors.rankTile(Ranks.groupOf('OCT')), AppColors.rankOfficerCadet);
    expect(
        AppColors.rankTile(Ranks.groupOf('CPT')), AppColors.rankJuniorOfficer);
    expect(
        AppColors.rankTile(Ranks.groupOf('COL')), AppColors.rankSeniorOfficer);
  });
}
