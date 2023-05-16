import 'package:firebase_project_2/src/utils/themes/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: const MaterialColor(
      0xFFFFE200,
      <int, Color>{
        50: Color.fromARGB(26, 191, 170, 16),
        100: Color.fromARGB(26, 174, 156, 15),
        200: Color.fromARGB(26, 152, 136, 14),
        300: Color.fromARGB(26, 128, 114, 12),
        400: Color.fromARGB(26, 150, 134, 12),
        500: Color.fromARGB(26, 124, 110, 4),
        600: Color.fromARGB(26, 109, 97, 9),
        700: Color.fromARGB(26, 115, 86, 7),
        800: Color.fromARGB(26, 129, 116, 16),
        900: Color.fromARGB(26, 167, 148, 5),
      },
    ),
    textTheme: OurTextTheme.lightTextTheme,
  );
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: const MaterialColor(
      0xFF36013F,
      <int, Color>{
        50: Color.fromARGB(26, 191, 170, 16),
        100: Color.fromARGB(26, 174, 156, 15),
        200: Color.fromARGB(26, 152, 136, 14),
        300: Color.fromARGB(26, 128, 114, 12),
        400: Color.fromARGB(26, 150, 134, 12),
        500: Color.fromARGB(26, 124, 110, 4),
        600: Color.fromARGB(26, 109, 97, 9),
        700: Color.fromARGB(26, 115, 86, 7),
        800: Color.fromARGB(26, 129, 116, 16),
        900: Color.fromARGB(26, 167, 148, 5),
      },
    ),
    textTheme: OurTextTheme.darkTextTheme,
  );
}
