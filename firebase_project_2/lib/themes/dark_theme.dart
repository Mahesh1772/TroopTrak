import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color.fromARGB(255, 72, 30, 229),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 32, 36, 51),
      background: Color.fromARGB(255, 21, 25, 34),
      secondary: Color.fromARGB(255, 72, 30, 229),
      tertiary: Colors.white,
    ),
    primaryTextTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.poppins(
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.poppins(
        color: Colors.white,
      ),
      titleSmall: GoogleFonts.poppins(
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.poppins(
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.poppins(
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.poppins(
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: Colors.white,
      ),
      headlineLarge: GoogleFonts.poppins(
        color: Colors.white,
      ),
      bodySmall: GoogleFonts.poppins(
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    appBarTheme: const AppBarTheme(
      color: Color.fromARGB(255, 72, 30, 229),
    ));
