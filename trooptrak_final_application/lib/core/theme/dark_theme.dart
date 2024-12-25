import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color.fromARGB(255, 72, 30, 229),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 32, 36, 51),
    surface: Color.fromARGB(255, 21, 25, 34),
    secondary: Color.fromARGB(255, 72, 30, 229),
    tertiary: Colors.white,
  ),
  textTheme: TextTheme(
    headlineSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    displayLarge: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 72, 30, 229),
  ),
); 