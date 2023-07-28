import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 215, 187, 245),
    background: Color.fromARGB(255, 237, 228, 255),
    secondary: Color.fromARGB(255, 72, 30, 229),
  ),
);
