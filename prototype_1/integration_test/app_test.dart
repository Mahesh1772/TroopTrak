import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prototype_1/main.dart' as app;
import 'package:prototype_1/screens/dashboard_screen/dashboard_screen.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(seconds: 2));
  group("Sign in, Registration and Forgot Password page tests", () {
    testWidgets("Verify login screen with the correct username and password",
        (tester) async {
      app.main();

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.enterText(
          find.byKey(const Key("emailField")), 'butteris242@gmail.com');
      await Future.delayed(const Duration(seconds: 2));
      await tester.enterText(
          find.byKey(const Key("passwordField")), 'Aakash02!');
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("signInButton")));
      await Future.delayed(const Duration(seconds: 2));

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 3));

      expect(find.byType(DashboardScreen), findsOneWidget);
      await Future.delayed(const Duration(seconds: 2));
    });

    testWidgets("Show error snackbar if entered username or password is wrong",
        (tester) async {
      app.main();

      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      await tester.enterText(find.byKey(const Key("emailField")), 'email');
      await Future.delayed(const Duration(seconds: 2));
      await tester.enterText(
          find.byKey(const Key("passwordField")), 'password!');
      await Future.delayed(const Duration(seconds: 2));

      await tester.tap(find.byKey(const Key("signInButton")));
      await Future.delayed(const Duration(seconds: 1));

      expect(find.text('Wrong Email/Password or Both'), findsOneWidget);
    });
  });
}
