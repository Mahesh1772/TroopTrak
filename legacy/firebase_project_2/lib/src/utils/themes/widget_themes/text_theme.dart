import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OurTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    headlineMedium: GoogleFonts.kanit(
      color: Colors.deepPurple.shade900,
      fontSize: 30,
    ),
    headlineLarge: GoogleFonts.kanit(
      color: Colors.deepPurple.shade600,
      fontSize: 20,
    ),
    headlineSmall: GoogleFonts.kanit(
      color: Colors.deepPurple.shade300,
      fontSize: 15,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    headlineMedium: GoogleFonts.kanit(
      color: const Color.fromARGB(255, 119, 243, 228),
      fontSize: 30,
    ),
    headlineLarge: GoogleFonts.kanit(
      color: const Color.fromARGB(255, 89, 226, 210),
      fontSize: 20,
    ),
    headlineSmall: GoogleFonts.kanit(
      color: const Color.fromARGB(255, 169, 246, 237),
      fontSize: 15,
    ),
  );
}
