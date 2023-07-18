import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype_1/main.dart' as app;
import 'package:prototype_1/screens/conduct_tracker_screen/conduct_tracker_screen.dart';
import 'package:prototype_1/sign_in_assets/authenticate/sign_in.dart';

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
      "Tests to check if a new conduct can be successfully added and becomes visible on the conduct tracker main page",
      () {
    testWidgets("Add a new conduct and see if it is reflected in the main page",
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

        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      await Future.delayed(const Duration(seconds: 10));
      await tester.tap(find.byKey(const Key("conductTracker")));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 6));

      expect(find.byType(ConductTrackerScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key("addConductPageRedirectButton")));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("conductType")));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.text("Route March"));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.enterText(find.byKey(const Key("conductName")), 'RM 6');

      await tester.tap(find.byKey(const Key("conductDate")));
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

      await tester.tap(find.byKey(const Key("addConductButton")));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text("RM 6"), findsAtLeastNWidgets(1));
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

        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      await Future.delayed(const Duration(seconds: 10));
      await tester.tap(find.byKey(const Key("conductTracker")));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 6));

      expect(find.byType(ConductTrackerScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key("addConductPageRedirectButton")));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("conductType")));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.text("Route March"));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.enterText(find.byKey(const Key("conductName")), 'RM 6');

      await tester.tap(find.byKey(const Key("conductDate")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("startTime")));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("addConductButton")));

      expect(find.text("Details missing"), findsAtLeastNWidgets(1));
    });
  });
}
