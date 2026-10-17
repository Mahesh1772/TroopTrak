import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trooptrak_final_application/core/constants/ranks.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_layout.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
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
    expect(theme.inputDecorationTheme.fillColor, AppColors.darkCard);
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
      expect(theme.chipTheme.selectedColor, AppColors.brandIndigo);
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
