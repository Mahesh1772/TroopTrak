import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trooptrak_final_application/app.dart';
import 'package:trooptrak_final_application/core/di/injection.dart';
import 'package:trooptrak_final_application/core/services/clock.dart';
import 'package:trooptrak_final_application/core/services/preferences_service.dart';
import 'package:trooptrak_final_application/core/theme/theme_manager.dart';

import 'helpers/pump_app.dart';

void main() {
  late AppDependencies dependencies;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dependencies =
        AppDependencies(preferences: await PreferencesService.create());
  });

  testWidgets('App builds with test DI and shows the placeholder home',
      (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(App(providers: dependencies.providers));
    await tester.pumpAndSettle();

    expect(find.text('TroopTrak'), findsOneWidget);
    final context = tester.element(find.text('TroopTrak'));
    expect(context.read<Clock>(), isA<SystemClock>());
    expect(context.read<PreferencesService>(), same(dependencies.preferences));
  });

  testWidgets('App starts dark and follows ThemeManager', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(App(providers: dependencies.providers));
    await tester.pumpAndSettle();

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.dark);

    tester.element(find.text('TroopTrak')).read<ThemeManager>().toggle();
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.light);
  });

  testWidgets('unknown routes show a not-found page', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
        App(providers: dependencies.providers, initialRoute: '/nope'));
    await tester.pumpAndSettle();
    expect(find.text('Page not found.'), findsOneWidget);
  });
}
