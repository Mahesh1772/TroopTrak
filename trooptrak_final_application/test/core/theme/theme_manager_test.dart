import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/theme/theme_manager.dart';

void main() {
  test('defaults to dark mode', () {
    final manager = ThemeManager();
    expect(manager.themeMode, ThemeMode.dark);
    expect(manager.isDark, isTrue);
  });

  test('toggle flips the mode and notifies each time', () {
    final manager = ThemeManager();
    var notified = 0;
    manager.addListener(() => notified++);

    manager.toggle();
    expect(manager.themeMode, ThemeMode.light);
    manager.toggle();
    expect(manager.themeMode, ThemeMode.dark);
    expect(notified, 2);
  });

  test('setDark only notifies on change', () {
    final manager = ThemeManager();
    var notified = 0;
    manager.addListener(() => notified++);

    manager.setDark(true);
    expect(notified, 0);
    manager.setDark(false);
    expect(manager.isDark, isFalse);
    expect(notified, 1);
  });
}
