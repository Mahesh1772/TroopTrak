import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  primaryColor: Colors.white,
  scaffoldBackgroundColor: const Color.fromARGB(255, 243, 246, 254),
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 219, 219, 219),
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
      fontWeight: FontWeight.bold, // Change the font weight here
      color: Colors.black,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold, // Change the font weight here
      color: Colors.black,
    ),
    displayLarge: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold, // Change the font weight here
      color: Colors.black,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal, // Change the font weight here
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal, // Change the font weight here
      color: Colors.black,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.normal, // Change the font weight here
      color: Colors.black,
    ),
    // Add more text styles as needed
  ),
);

final ThemeData darkTheme = ThemeData(
  primaryColor: Colors.black,
  scaffoldBackgroundColor: const Color.fromARGB(255, 21, 25, 34),
  secondaryHeaderColor: Colors.purpleAccent,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 32, 36, 51),
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
      fontWeight: FontWeight.bold, // Change the font weight here
      color: Colors.white,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold, // Change the font weight here
      color: Colors.white,
    ),
    displayLarge: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold, // Change the font weight here
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal, // Change the font weight here
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal, // Change the font weight here
      color: Colors.white,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.normal, // Change the font weight here
      color: Colors.white,
    ),
    // Add more text styles as needed
  ),
);
