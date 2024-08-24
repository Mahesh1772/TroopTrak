import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.white,
    secondaryHeaderColor: Colors.purpleAccent,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      headlineSmall: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.black,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.black,
      ),
      displayLarge: GoogleFonts.poppins(
        fontSize: 28.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.black,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.black,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.black,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.black,
      ),
      // Add more text styles as needed
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.black,
    secondaryHeaderColor: Colors.purpleAccent,
    scaffoldBackgroundColor: Colors.black,
    textTheme: TextTheme(
      headlineSmall: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.white,
      ),
      displayLarge: GoogleFonts.poppins(
        fontSize: 28.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.white,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.normal, // Change the font weight here
        color: Colors.white,
      ),
      // Add more text styles as needed
    ),
  );
}
