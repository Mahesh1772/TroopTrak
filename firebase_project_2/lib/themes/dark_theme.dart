import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color.fromARGB(255, 72, 30, 229),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 32, 36, 51),
    background: Color.fromARGB(255, 21, 25, 34),
    secondary: Color.fromARGB(255, 72, 30, 229),
  ),
);
