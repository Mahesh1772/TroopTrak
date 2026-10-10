import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

ThemeData buildAppTheme({
  required ColorScheme scheme,
  required AppPalette palette,
  required Color appBarColor,
}) {
  final text = AppTextStyles.textTheme(scheme.onSurface);
  final rounded = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadii.lg),
  );
  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.lg),
    borderSide: BorderSide.none,
  );

  WidgetStateProperty<Color?> selected(Color on, Color? off) =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? on : off,
      );

  Color selectedColor(Color on, Color off) => WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected) ? on : off,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text,
    primaryTextTheme: text,
    iconTheme: IconThemeData(color: scheme.tertiary),
    extensions: [palette],
    appBarTheme: AppBarTheme(
      backgroundColor: appBarColor,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      titleTextStyle: text.headlineLarge,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.brandIndigo,
      foregroundColor: AppColors.white,
    ),
    cardTheme: CardThemeData(
      color: palette.card,
      elevation: 2,
      shadowColor: palette.shadow,
      shape: rounded,
      margin: EdgeInsets.zero,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.card,
      shape: rounded,
      titleTextStyle: text.headlineLarge,
      contentTextStyle: text.bodyMedium,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.card,
      hintStyle: text.bodySmall?.copyWith(color: palette.muted),
      labelStyle: text.bodySmall?.copyWith(color: palette.muted),
      prefixIconColor: palette.muted,
      suffixIconColor: palette.muted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      errorBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      errorStyle: text.labelSmall?.copyWith(color: AppColors.danger),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.card,
      selectedColor: AppColors.brandIndigo,
      checkmarkColor: AppColors.white,
      labelStyle: text.labelMedium,
      secondaryLabelStyle: text.labelMedium?.copyWith(color: AppColors.white),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandIndigo,
        foregroundColor: AppColors.white,
        textStyle: text.labelLarge,
        shape: rounded,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: text.labelLarge,
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: scheme.onSurface,
      unselectedLabelColor: palette.muted,
      indicatorColor: AppColors.accent,
      labelStyle: text.titleSmall,
      unselectedLabelStyle: text.titleSmall,
      dividerColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.cardElevated,
      contentTextStyle: text.bodySmall?.copyWith(color: palette.onCard),
      shape: rounded,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: palette.card,
      headerBackgroundColor: AppColors.accent,
      headerForegroundColor: AppColors.white,
      dayForegroundColor: selected(AppColors.white, scheme.onSurface),
      dayBackgroundColor: selected(AppColors.accent, null),
      yearForegroundColor: selected(AppColors.white, scheme.onSurface),
      yearBackgroundColor: selected(AppColors.accent, null),
      todayForegroundColor: selected(AppColors.white, AppColors.accent),
      todayBackgroundColor: selected(AppColors.accent, null),
      todayBorder: const BorderSide(color: AppColors.accent),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: palette.card,
      dialHandColor: AppColors.accent,
      dialBackgroundColor: palette.cardElevated,
      hourMinuteColor: selectedColor(AppColors.accent, palette.cardElevated),
      hourMinuteTextColor: selectedColor(AppColors.white, scheme.onSurface),
      dayPeriodColor: selectedColor(AppColors.accent, palette.cardElevated),
      dayPeriodTextColor: selectedColor(AppColors.white, scheme.onSurface),
      entryModeIconColor: AppColors.accent,
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurface,
      ),
    ),
  );
}
