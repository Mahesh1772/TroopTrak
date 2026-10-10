import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_theme_builder.dart';

const lightColorScheme = ColorScheme.light(
  primary: AppColors.lightPrimary,
  onPrimary: AppColors.black,
  secondary: AppColors.brandIndigo,
  onSecondary: AppColors.white,
  tertiary: AppColors.black,
  onTertiary: AppColors.white,
  surface: AppColors.lightSurface,
  onSurface: AppColors.black,
  error: AppColors.danger,
  onError: AppColors.white,
);

ThemeData buildLightTheme() => buildAppTheme(
      scheme: lightColorScheme,
      palette: AppPalette.light,
      appBarColor: AppColors.lightPrimary,
    );
