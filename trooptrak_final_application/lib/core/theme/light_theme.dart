import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 219, 219, 219),
    surface: Color.fromARGB(255, 243, 246, 254),
    secondary: Color.fromARGB(255, 72, 30, 229),
    tertiary: Colors.black,
  ),
  textTheme: TextTheme(
    headlineSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    displayLarge: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 219, 219, 219),
  ),
); 