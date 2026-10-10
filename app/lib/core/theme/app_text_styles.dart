import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle poppins(double size, FontWeight weight, Color color) =>
      GoogleFonts.poppins(fontSize: size.sp, fontWeight: weight, color: color);

  static TextTheme textTheme(Color color) => TextTheme(
        displayLarge: poppins(28, FontWeight.bold, color),
        displayMedium: poppins(24, FontWeight.bold, color),
        displaySmall: poppins(20, FontWeight.bold, color),
        headlineLarge: poppins(18, FontWeight.bold, color),
        headlineMedium: poppins(16, FontWeight.bold, color),
        headlineSmall: poppins(14, FontWeight.bold, color),
        titleLarge: poppins(18, FontWeight.w500, color),
        titleMedium: poppins(16, FontWeight.w500, color),
        titleSmall: poppins(14, FontWeight.w500, color),
        bodyLarge: poppins(18, FontWeight.normal, color),
        bodyMedium: poppins(16, FontWeight.normal, color),
        bodySmall: poppins(14, FontWeight.normal, color),
        labelLarge: poppins(16, FontWeight.w600, color),
        labelMedium: poppins(14, FontWeight.w500, color),
        labelSmall: poppins(12, FontWeight.w500, color),
      );
}
