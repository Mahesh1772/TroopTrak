import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trooptrak_final_application/core/di/injection.dart';
import 'package:trooptrak_final_application/core/services/preferences_service.dart';

void main() {
  Future<AppDependencies> dependenciesWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return AppDependencies(preferences: await PreferencesService.create());
  }

  test('starts dark when nothing is saved', () async {
    final manager = (await dependenciesWith({})).createThemeManager();
    expect(manager.themeMode, ThemeMode.dark);
  });

  test('starts from a saved light mode and saves a toggle', () async {
    final dependencies = await dependenciesWith({'theme_dark': false});
    final manager = dependencies.createThemeManager();
    expect(manager.themeMode, ThemeMode.light);

    manager.toggle();
    await pumpEventQueue();

    expect(dependencies.preferences.isDarkTheme, isTrue);
    expect((await SharedPreferences.getInstance()).getBool('theme_dark'), true);
  });

  test('a saved toggle is picked up by the next launch', () async {
    final dependencies = await dependenciesWith({});
    dependencies.createThemeManager().toggle();
    await pumpEventQueue();

    final nextLaunch = AppDependencies(
      preferences: await PreferencesService.create(),
    );
    expect(nextLaunch.createThemeManager().themeMode, ThemeMode.light);
  });
}
