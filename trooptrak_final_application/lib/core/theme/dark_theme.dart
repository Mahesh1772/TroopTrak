import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_theme_builder.dart';

const darkColorScheme = ColorScheme.dark(
  primary: AppColors.darkPrimary,
  onPrimary: AppColors.white,
  secondary: AppColors.brandIndigo,
  onSecondary: AppColors.white,
  tertiary: AppColors.white,
  onTertiary: AppColors.black,
  surface: AppColors.darkSurface,
  onSurface: AppColors.white,
  error: AppColors.danger,
  onError: AppColors.white,
);

ThemeData buildDarkTheme() => buildAppTheme(
      scheme: darkColorScheme,
      palette: AppPalette.dark,
      appBarColor: AppColors.brandIndigo,
    );
