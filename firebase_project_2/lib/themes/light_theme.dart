import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 219, 219, 219),
    background: Color.fromARGB(255, 243, 246, 254),
    secondary: Color.fromARGB(255, 72, 30, 229),
    tertiary: Colors.black,
  ),
  primaryTextTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(
      color: Colors.black,
    ),
    displayMedium: GoogleFonts.poppins(
      color: Colors.black,
    ),
    displaySmall: GoogleFonts.poppins(
      color: Colors.black,
    ),
    titleSmall: GoogleFonts.poppins(
      color: Colors.black,
    ),
    titleMedium: GoogleFonts.poppins(
      color: Colors.black,
    ),
    titleLarge: GoogleFonts.poppins(
      color: Colors.black,
    ),
    headlineSmall: GoogleFonts.poppins(
      color: Colors.black,
    ),
    headlineMedium: GoogleFonts.poppins(
      color: Colors.black,
    ),
    headlineLarge: GoogleFonts.poppins(
      color: Colors.black,
    ),
    bodySmall: GoogleFonts.poppins(
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.poppins(
      color: Colors.black,
    ),
    bodyLarge: GoogleFonts.poppins(
      color: Colors.black,
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  appBarTheme: const AppBarTheme(
    color: Color.fromARGB(255, 243, 246, 254),
  ),
);
