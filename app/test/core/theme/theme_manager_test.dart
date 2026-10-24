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

  test('onChanged is called once per real change and not for a no-op', () {
    final changes = <ThemeMode>[];
    final manager = ThemeManager(onChanged: changes.add);

    manager.setDark(true);
    expect(changes, isEmpty);
    manager.setDark(false);
    manager.setDark(false);
    manager.toggle();
    expect(changes, [ThemeMode.light, ThemeMode.dark]);
  });

  test('starts from the initial mode without calling onChanged', () {
    final changes = <ThemeMode>[];
    final manager =
        ThemeManager(initialMode: ThemeMode.light, onChanged: changes.add);
    expect(manager.isDark, isFalse);
    expect(changes, isEmpty);
  });

  test('works with no callback', () {
    final manager = ThemeManager()..toggle();
    expect(manager.themeMode, ThemeMode.light);
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
