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
import 'package:trooptrak_final_application/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:trooptrak_final_application/features/attendance/domain/usecases/watch_soldiers_in_camp.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/auth_usecases.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/complete_soldier_profile.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/delete_commander_account.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/build_conduct_roster.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/conduct_usecases.dart';
import 'package:trooptrak_final_application/features/conducts/domain/usecases/watch_conduct_breakdown.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/usecases/men_usecases.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/usecases/duty_usecases.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/usecases/soldier_usecases.dart';
import 'package:trooptrak_final_application/features/statuses/domain/usecases/status_usecases.dart';

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

  testWidgets('every use case a route reads is registered', (tester) async {
    useDesignSurface(tester);
    await tester
        .pumpWidget(App(providers: (await dependenciesWith({})).providers));
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Please pick your role.'));
    for (final read in <Object Function()>[
      () => context.read<WatchSoldier>(),
      () => context.read<WatchSoldiers>(),
      () => context.read<AddSoldier>(),
      () => context.read<UpdateSoldier>(),
      () => context.read<DeleteSoldier>(),
      () => context.read<WatchSoldierStatuses>(),
      () => context.read<AddStatus>(),
      () => context.read<UpdateStatus>(),
      () => context.read<DeleteStatus>(),
      () => context.read<WatchAttendance>(),
      () => context.read<UpdateAttendance>(),
      () => context.read<DeleteAttendance>(),
      () => context.read<BookInOut>(),
      () => context.read<WatchSoldiersInCamp>(),
      () => context.read<FindRegistrationByQr>(),
      () => context.read<CompleteSoldierProfile>(),
      () => context.read<DeleteCommanderAccount>(),
      () => context.read<SignOut>(),
      () => context.read<WatchConductsOnDay>(),
      () => context.read<AddConduct>(),
      () => context.read<UpdateConduct>(),
      () => context.read<DeleteConduct>(),
      () => context.read<BuildConductRoster>(),
      () => context.read<WatchConductBreakdown>(),
      () => context.read<WatchDuties>(),
      () => context.read<AddDuty>(),
      () => context.read<UpdateDuty>(),
      () => context.read<DeleteDuty>(),
      () => context.read<GetDutyEligibleSoldiers>(),
    ]) {
      expect(read, returnsNormally);
    }
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
