import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Colors.white70,
    background: Colors.white70,
    secondary: Color.fromARGB(255, 72, 30, 229),
  ),
);
