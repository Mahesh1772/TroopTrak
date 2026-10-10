import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/complete_soldier_profile.dart';
import 'package:trooptrak_final_application/features/auth/presentation/pages/profile_capture_page.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/pump_app.dart';

class _MockComplete extends Mock implements CompleteSoldierProfile {}

void main() {
  late _MockComplete complete;

  setUpAll(() => registerFallbackValue(buildSoldier()));

  setUp(() {
    complete = _MockComplete();
    when(() => complete(any())).thenAnswer((_) async => const Right(unit));
  });

  Future<RouteRecorder> pumpPage(WidgetTester tester,
      {ThemeMode mode = ThemeMode.dark}) async {
    final recorder = RouteRecorder();
    await tester.pumpApp(
      const ProfileCapturePage(),
      mode: mode,
      providers: [Provider<CompleteSoldierProfile>.value(value: complete)],
      observers: [recorder],
    );
    return recorder;
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    final button = find.byKey(const Key('captureButton'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String key, String item) async {
    final field = find.byKey(Key(key));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.text(item).last);
    await tester.pumpAndSettle();
  }

  Future<void> pickDate(WidgetTester tester, String key, int day) async {
    final field = find.byKey(Key(key));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(
        find.descendant(of: find.byType(Dialog), matching: find.text('$day')));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  Future<void> fillAll(WidgetTester tester, {String name = 'Lim Bah'}) async {
    for (final (key, value) in [
      ('profile-name', name),
      ('profile-appointment', 'Rifleman'),
      ('profile-company', 'Alpha'),
      ('profile-platoon', '1'),
      ('profile-section', '3'),
    ]) {
      await tester.enterText(find.byKey(Key(key)), value);
    }
    await choose(tester, 'profile-ration', 'NM');
    await choose(tester, 'profile-rank', 'PTE');
    await choose(tester, 'profile-blood', 'O+');
    await pickDate(tester, 'profile-dob', 1);
    await pickDate(tester, 'profile-enlistment', 2);
    await pickDate(tester, 'profile-ord', 3);
  }

  testWidgets('renders the source heading and the dates start empty',
      (tester) async {
    await pumpPage(tester, mode: themeModes.currentValue!);
    expect(find.text("Let's get things set up  ✍️"), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Enlistment Date'), findsOneWidget);
    expect(find.text('ORD'), findsOneWidget);
    expect(find.text('5 Jul 2023'), findsNothing);
  }, variant: themeModes);

  testWidgets('empty submit shows every validator and no save', (tester) async {
    await pumpPage(tester);
    await tapSubmit(tester);
    for (final message in [
      'Must have a name right',
      'Appointment Missing',
      'Walao what food you eat?',
      'Walao provide rank liao',
      'Why your blood field empty ah?',
      'Company Name Missing',
      'Platoon Information Missing',
      'Section Information Missing',
      'Select your date of birth',
      'Select your enlistment date',
      'Select your ORD date',
    ]) {
      await tester.ensureVisible(find.text(message));
      expect(find.text(message), findsOneWidget, reason: message);
    }
    expect(find.text('Details missing'), findsOneWidget);
    verifyNever(() => complete(any()));
  });

  for (final (name, message) in [
    ('12345', 'Name got number meh'),
    ('Lim', 'Brother, enter full name leh'),
  ]) {
    testWidgets('name "$name" shows "$message"', (tester) async {
      await pumpPage(tester);
      await tester.enterText(find.byKey(const Key('profile-name')), name);
      await tester.pumpAndSettle();
      expect(find.text(message), findsOneWidget);
    });
  }

  testWidgets('rank offers only the self-registration list', (tester) async {
    await pumpPage(tester);
    final field = find.byKey(const Key('profile-rank'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.tap(field);
    await tester.pumpAndSettle();
    for (final rank in ['REC', 'PTE', 'LCP', 'CPL', 'CFC', 'SCT', 'OCT']) {
      expect(find.text(rank), findsWidgets);
    }
    expect(find.text('3SG'), findsNothing);
    expect(find.text('2LT'), findsNothing);
  });

  testWidgets('a picked date clears its error', (tester) async {
    await pumpPage(tester);
    await tapSubmit(tester);
    expect(find.text('Select your ORD date'), findsOneWidget);
    await pickDate(tester, 'profile-ord', 3);
    expect(find.text('Select your ORD date'), findsNothing);
    expect(find.text('3 Jul 2023'), findsOneWidget);
  });

  testWidgets('valid submit saves the profile and opens the soldier home',
      (tester) async {
    final recorder = await pumpPage(tester);
    await fillAll(tester);
    await tapSubmit(tester);

    final saved =
        verify(() => complete(captureAny())).captured.single as Soldier;
    expect(
      saved,
      Soldier(
        id: '',
        name: 'Lim Bah',
        rank: 'PTE',
        company: 'Alpha',
        platoon: '1',
        section: '3',
        appointment: 'Rifleman',
        rationType: 'NM',
        bloodGroup: 'O+',
        dob: DateTime(2023, 7, 1),
        enlistment: DateTime(2023, 7, 2),
        ord: DateTime(2023, 7, 3),
      ),
    );
    expect(recorder.names.last, AppRoutes.soldierHome);
    expect(find.text('Soldier tile created'), findsOneWidget);
  });

  testWidgets('a failed save shows the message and stays', (tester) async {
    when(() => complete(any()))
        .thenAnswer((_) async => const Left(ServerFailure('Network down')));
    final recorder = await pumpPage(tester);
    await fillAll(tester);
    await tapSubmit(tester);
    expect(find.text('Network down'), findsOneWidget);
    expect(recorder.names, isNot(contains(AppRoutes.soldierHome)));
  });
}
