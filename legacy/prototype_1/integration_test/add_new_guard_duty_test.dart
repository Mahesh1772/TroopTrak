import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype_1/main.dart' as app;
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/tabs/points_leaderboard.dart';
import 'package:prototype_1/sign_in_assets/authenticate/sign_in.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<bool> isPresent(Finder finder,
      {Duration timeout = const Duration(seconds: 1)}) async {
    try {
      expect(finder, findsOneWidget);
      return true;
    } catch (e) {
      return false;
    }
  }

  setUpAll(() {
    // this will start the app for each subsequent test
    app.main();
  });

  group(
      "Tests to check if a new guard duty can be successfully added and becomes visible on the upcoming duties tab",
      () {
    testWidgets(
        "Add a new guard duty and see if it is reflected in the upcoming duties page",
        (tester) async {
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (await isPresent(find.byType(SignIn))) {
        await tester.enterText(
            find.byKey(const Key("emailField")), 'butteris242@gmail.com');
        await Future.delayed(const Duration(seconds: 3));
        await tester.enterText(
            find.byKey(const Key("passwordField")), 'Aakash02!');
        await Future.delayed(const Duration(seconds: 3));

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await tester.tap(find.byKey(const Key("signInButton")));

        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      await Future.delayed(const Duration(seconds: 10));
      await tester.tap(find.byKey(const Key("guardDuty")));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      expect(find.byType(PointsLeaderBoard), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("add-duty-soldiers-hero-0")));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byType(RoundCheckBox).at(0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RoundCheckBox).at(1));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RoundCheckBox).at(2));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("addSoldiersToDuty")));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("startDate")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("startTime")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("endTime")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("addGuardDutyButton")));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.text("UPCOMING DUTIES"));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      expect(find.text("17 Jul 2023"), findsAtLeastNWidgets(1));
      expect(find.text("1.0"), findsAtLeastNWidgets(1));
    });

    testWidgets(
        "Attempt to submit an incomplete form when adding a new conduct",
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      if (await isPresent(find.byType(SignIn))) {
        await tester.enterText(
            find.byKey(const Key("emailField")), 'butteris242@gmail.com');
        await Future.delayed(const Duration(seconds: 3));
        await tester.enterText(
            find.byKey(const Key("passwordField")), 'Aakash02!');
        await Future.delayed(const Duration(seconds: 3));

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await tester.tap(find.byKey(const Key("signInButton")));

        await tester.pumpAndSettle(const Duration(seconds: 30));
      }

      await Future.delayed(const Duration(seconds: 10));
      await tester.tap(find.byKey(const Key("guardDuty")));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      expect(find.byType(PointsLeaderBoard), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("add-duty-soldiers-hero-0")));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byType(RoundCheckBox).at(0));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RoundCheckBox).at(1));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RoundCheckBox).at(2));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("addSoldiersToDuty")));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("startDate")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("startTime")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("addGuardDutyButton")));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text("Details missing"), findsAtLeastNWidgets(1));
    });
  });
}
