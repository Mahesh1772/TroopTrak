import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  ThemeManager({ThemeMode initialMode = ThemeMode.dark})
      : _themeMode = initialMode;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggle() => setDark(!isDark);

  void setDark(bool dark) {
    final mode = dark ? ThemeMode.dark : ThemeMode.light;
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
  }
}
