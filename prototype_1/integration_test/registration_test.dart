import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype_1/main.dart' as app;
import 'package:prototype_1/screens/dashboard_screen/dashboard_screen.dart';
import 'package:prototype_1/sign_in_assets/authenticate/register_page.dart';

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

  group("Registration page tests", () {
    testWidgets("Ensure button press correctly redirects to registration page",
        (tester) async {
      await tester.pumpAndSettle();

      if (await isPresent(find.byType(DashboardScreen))) {
        await tester.tap(find.byKey(const Key("userProfileIcon")));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.tap(find.byKey(const Key("signOutButton")));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      await tester.tap(find.byKey(const Key("registerPageButton")));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      expect(find.byType(RegisterPage), findsOneWidget);

      await tester.enterText(find.byKey(const Key("name")), 'John Doe');

      await tester.enterText(
          find.byKey(const Key("appointment")), 'Section Commander');

      await tester.tap(find.byKey(const Key("rationType")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("SD NM"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("rank")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("3SG"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("bloodType")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("O+"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.enterText(find.byKey(const Key("company")), 'Charlie');

      await tester.enterText(find.byKey(const Key("platoon")), '3');

      await tester.enterText(find.byKey(const Key("section")), '2');

      await tester.enterText(find.byKey(const Key("password")), 'Password01!');

      await tester.enterText(
          find.byKey(const Key("confirmPassword")), 'Password01!');

      await tester.tap(find.byKey(const Key("signUpButton")));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text("Email can not be empty"), findsOneWidget);
    });
  });
}
