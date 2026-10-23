import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle barlow(double size, FontWeight weight, Color color) {
    assert(weight.value >= 400 && weight.value <= 700,
        'Barlow is bundled at w400-w700 only');
    return GoogleFonts.barlow(
        fontSize: size.sp, fontWeight: weight, color: color);
  }

  static TextStyle pageTitle(Color color) => barlow(24, FontWeight.w600, color);

  static TextStyle profileName(Color color) {
    final style = barlow(24, FontWeight.w700, color);
    return style.copyWith(letterSpacing: style.fontSize! * 0.01, height: 1.1);
  }

  static TextStyle headerTitle(Color color) =>
      barlow(28, FontWeight.w700, color).copyWith(height: 1.1);

  static TextStyle compactTitle(Color color) =>
      barlow(20, FontWeight.w600, color);

  static TextStyle subtitle(Color color) =>
      barlow(14.5, FontWeight.w400, color);

  static TextStyle h2(Color color) => barlow(18, FontWeight.w600, color);

  static TextStyle h3(Color color) => barlow(16, FontWeight.w600, color);

  static TextStyle caption(Color color) => barlow(13, FontWeight.w400, color);

  static TextStyle badge(Color color) => barlow(13, FontWeight.w600, color);

  static TextStyle cardTitle(Color color) => barlow(21, FontWeight.w700, color);

  static TextStyle overline(Color color) {
    final style = barlow(12.5, FontWeight.w700, color);
    return style.copyWith(letterSpacing: style.fontSize! * 0.08);
  }

  static TextStyle columnHeader(Color color) {
    final style = barlow(13, FontWeight.w600, color);
    return style.copyWith(letterSpacing: style.fontSize! * 0.04);
  }

  static TextStyle rowLabel(Color color) {
    final style = barlow(15, FontWeight.w600, color);
    return style.copyWith(letterSpacing: style.fontSize! * 0.04);
  }

  static TextStyle figure(double size, FontWeight weight, Color color) {
    assert(weight.value >= 500 && weight.value <= 700,
        'Barlow Condensed is bundled at w500-w700 only');
    return GoogleFonts.barlowCondensed(
      fontSize: size.sp,
      fontWeight: weight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextTheme textTheme(Color color) => TextTheme(
        displayLarge: barlow(28, FontWeight.bold, color),
        displayMedium: barlow(24, FontWeight.bold, color),
        displaySmall: barlow(20, FontWeight.bold, color),
        headlineLarge: barlow(18, FontWeight.bold, color),
        headlineMedium: barlow(16, FontWeight.bold, color),
        headlineSmall: barlow(14, FontWeight.bold, color),
        titleLarge: barlow(18, FontWeight.w500, color),
        titleMedium: barlow(16, FontWeight.w500, color),
        titleSmall: barlow(14, FontWeight.w500, color),
        bodyLarge: barlow(16, FontWeight.normal, color),
        bodyMedium: barlow(16, FontWeight.normal, color),
        bodySmall: barlow(14, FontWeight.normal, color),
        labelLarge: barlow(16, FontWeight.w600, color),
        labelMedium: barlow(14, FontWeight.w500, color),
        labelSmall: barlow(12, FontWeight.w500, color),
      );
}
