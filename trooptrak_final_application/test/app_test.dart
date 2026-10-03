import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
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
  Future<AppDependencies> dependenciesWith(
    Map<String, Object> prefs, {
    MockFirebaseAuth? auth,
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    return AppDependencies(
      preferences: await PreferencesService.create(),
      firestore: FakeFirebaseFirestore(),
      auth: auth ?? MockFirebaseAuth(),
    );
  }

  testWidgets('first launch shows role selection with test DI', (tester) async {
    useDesignSurface(tester);
    final dependencies = await dependenciesWith({});
    await tester.pumpWidget(App(providers: dependencies.providers));
    await tester.pumpAndSettle();

    expect(find.text('Please pick your role.'), findsOneWidget);
    final context = tester.element(find.text('Please pick your role.'));
    expect(context.read<Clock>(), isA<SystemClock>());
    expect(context.read<PreferencesService>(), same(dependencies.preferences));
  });

  testWidgets('commander role opens the sign-in gate (R18, R19)',
      (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(
        App(providers: (await dependenciesWith({'onBoard': 2})).providers));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to camp!'), findsOneWidget);
  });

  testWidgets('signed-in commander goes straight to the commander app',
      (tester) async {
    useDesignSurface(tester);
    final deps = await dependenciesWith({'onBoard': 2},
        auth: MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'c1')));
    await tester.pumpWidget(App(providers: deps.providers));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.byKey(const Key('userProfileIcon')), findsOneWidget);
  });

  testWidgets('App starts dark and follows ThemeManager', (tester) async {
    useDesignSurface(tester);
    await tester
        .pumpWidget(App(providers: (await dependenciesWith({})).providers));
    await tester.pumpAndSettle();

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.dark);

    tester
        .element(find.text('Please pick your role.'))
        .read<ThemeManager>()
        .toggle();
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.light);
  });

  testWidgets('unknown routes show a not-found page', (tester) async {
    useDesignSurface(tester);
    await tester.pumpWidget(App(
        providers: (await dependenciesWith({})).providers,
        initialRoute: '/nope'));
    await tester.pumpAndSettle();
    expect(find.text('Page not found.'), findsOneWidget);
  });
}
