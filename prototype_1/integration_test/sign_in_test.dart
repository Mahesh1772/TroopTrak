import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype_1/main.dart' as app;
import 'package:prototype_1/screens/dashboard_screen/dashboard_screen.dart';

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

  group("Sign in page tests", () {
    testWidgets("Verify login screen with the correct username and password",
        (tester) async {
      await tester.pumpAndSettle();

      if (await isPresent(find.byType(DashboardScreen))) {
        await tester.tap(find.byKey(const Key("userProfileIcon")));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.tap(find.byKey(const Key("signOutButton")));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      await tester.enterText(
          find.byKey(const Key("emailField")), 'butteris242@gmail.com');
      await Future.delayed(const Duration(seconds: 3));
      await tester.enterText(
          find.byKey(const Key("passwordField")), 'Aakash02!');
      await Future.delayed(const Duration(seconds: 3));

      await tester.tap(find.byKey(const Key("signInButton")));

      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets("Show error snackbar if entered username or password is wrong",
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      if (await isPresent(find.byType(DashboardScreen))) {
        await tester.tap(find.byKey(const Key("userProfileIcon")));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.tap(find.byKey(const Key("signOutButton")));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      await tester.enterText(
          find.byKey(const Key("emailField")), 'email@emailaddress.com');
      await Future.delayed(const Duration(seconds: 2));
      await tester.enterText(
          find.byKey(const Key("passwordField")), 'password!');

      await tester.tap(find.byKey(const Key("signInButton")));
      await Future.delayed(const Duration(seconds: 4));

      expect(find.text('Wrong Email/Password or Both'), findsOneWidget);
    });

    testWidgets(
        "Show snackbar prompting user to fill in all fields if entered username or password is empty",
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      if (await isPresent(find.byType(DashboardScreen))) {
        await tester.tap(find.byKey(const Key("userProfileIcon")));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await tester.tap(find.byKey(const Key("signOutButton")));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      await Future.delayed(const Duration(seconds: 2));
      await tester.enterText(
          find.byKey(const Key("passwordField")), 'password!');

      await tester.tap(find.byKey(const Key("signInButton")));
      Future.delayed(const Duration(seconds: 2));

      expect(find.text('Fill in all the fields'), findsOneWidget);
    });
  });
}
