import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/constants/ranks.dart';
import 'package:trooptrak_final_application/core/theme/app_colors.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/theme/dark_theme.dart';
import 'package:trooptrak_final_application/core/theme/light_theme.dart';
import 'package:trooptrak_final_application/core/theme/theme_context.dart';

Future<ThemeData> _build(
    WidgetTester tester, ThemeData Function() builder) async {
  late ThemeData theme;
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(450, 1000),
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

  testWidgets('text theme uses Poppins', (tester) async {
    final theme = await _build(tester, buildDarkTheme);
    expect(theme.textTheme.bodyMedium?.fontFamily, contains('Poppins'));
    expect(theme.textTheme.headlineLarge?.fontWeight, FontWeight.bold);
  });

  testWidgets('context extension exposes palette and brightness',
      (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(450, 1000),
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
