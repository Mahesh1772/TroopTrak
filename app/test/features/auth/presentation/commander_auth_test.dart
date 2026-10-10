import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/auth_usecases.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/register_commander.dart';
import 'package:trooptrak_final_application/features/auth/presentation/pages/commander_auth_gate.dart';
import 'package:trooptrak_final_application/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:trooptrak_final_application/features/auth/presentation/providers/commander_auth_provider.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/pump_app.dart';

class _MockSignIn extends Mock implements SignInWithEmail {}

class _MockRegister extends Mock implements RegisterCommander {}

class _MockReset extends Mock implements SendPasswordReset {}

class _MockWatch extends Mock implements WatchAuthState {}

void main() {
  late _MockSignIn signIn;
  late _MockRegister register;
  late _MockReset reset;

  setUpAll(() {
    registerFallbackValue(const EmailCredentials('', ''));
    registerFallbackValue(CommanderRegistration(
        email: '', password: '', profile: buildSoldier()));
  });

  setUp(() {
    signIn = _MockSignIn();
    register = _MockRegister();
    reset = _MockReset();
    when(() => signIn(any()))
        .thenAnswer((_) async => const Right(AuthUser(uid: 'c1')));
    when(() => register(any())).thenAnswer((_) async => const Right(unit));
    when(() => reset(any())).thenAnswer((_) async => const Right(unit));
  });

  CommanderAuthProvider provider() => CommanderAuthProvider(
      signIn: signIn, register: register, sendReset: reset);

  group('CommanderAuthProvider', () {
    test('sign in success returns null; auth failures read as the source text',
        () async {
      final p = provider();
      expect(await p.signIn('cmd@unit.sg', 'password1'), isNull);
      when(() => signIn(any())).thenAnswer(
          (_) async => const Left(AuthFailure('bad', code: 'wrong-password')));
      expect(await p.signIn('cmd@unit.sg', 'password1'),
          'Wrong Email/Password or Both');
      expect(p.loading, isFalse);
    });

    test('validation failures keep their own message', () async {
      when(() => register(any())).thenAnswer((_) async =>
          const Left(ValidationFailure('A soldier named X already exists.')));
      expect(
          await provider().register(CommanderRegistration(
              email: 'a@b.c', password: 'x', profile: buildSoldier())),
          'A soldier named X already exists.');
    });

    test('register success flips back to sign in', () async {
      final p = provider()..toggleMode();
      expect(p.mode, CommanderAuthMode.register);
      expect(
          await p.register(CommanderRegistration(
              email: 'a@b.c', password: 'x', profile: buildSoldier())),
          isNull);
      expect(p.mode, CommanderAuthMode.signIn);
    });

    test('register auth failure reads as the source text', () async {
      when(() => register(any()))
          .thenAnswer((_) async => const Left(AuthFailure('in use')));
      expect(
          await provider().register(CommanderRegistration(
              email: 'a@b.c', password: 'x', profile: buildSoldier())),
          'This Email in use/ Enter Email and Password');
    });

    test('password reset returns the failure message', () async {
      final p = provider();
      expect(await p.sendPasswordReset('cmd@unit.sg'), isNull);
      when(() => reset(any()))
          .thenAnswer((_) async => const Left(AuthFailure('No user')));
      expect(await p.sendPasswordReset('cmd@unit.sg'), 'No user');
    });
  });

  group('CommanderAuthGate', () {
    late StreamController<AuthUser?> auth;
    late _MockWatch watch;

    setUp(() {
      auth = StreamController<AuthUser?>.broadcast();
      watch = _MockWatch();
      when(() => watch()).thenAnswer((_) => auth.stream);
      when(() => watch.current).thenReturn(null);
    });
    tearDown(() => auth.close());

    Future<RouteRecorder> pumpGate(WidgetTester tester,
        {ThemeMode mode = ThemeMode.dark}) async {
      final recorder = RouteRecorder();
      await tester.pumpApp(
        ChangeNotifierProvider(
          create: (_) => provider(),
          child: CommanderAuthGate(signedIn: (_) => const Text('HOME')),
        ),
        mode: mode,
        providers: [Provider<WatchAuthState>.value(value: watch)],
        observers: [recorder],
      );
      return recorder;
    }

    testWidgets('signed out shows sign in; a signed-in user shows home (R19)',
        (tester) async {
      await pumpGate(tester, mode: themeModes.currentValue!);
      expect(find.text('Welcome to camp!'), findsOneWidget);

      auth.add(const AuthUser(uid: 'c1'));
      await tester.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);

      auth.add(null);
      await tester.pumpAndSettle();
      expect(find.text('Welcome to camp!'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('empty sign-in shows validation messages and no call',
        (tester) async {
      await pumpGate(tester);
      await tester.tap(find.byKey(const Key('signInButton')));
      await tester.pumpAndSettle();
      expect(find.text('Email can not be empty'), findsOneWidget);
      expect(find.text('Password can not be empty'), findsOneWidget);
      expect(find.text('Fill in all the fields'), findsOneWidget);
      verifyNever(() => signIn(any()));
    });

    testWidgets('valid sign-in calls the use case and shows success',
        (tester) async {
      await pumpGate(tester);
      await tester.enterText(find.byKey(const Key('email')), 'cmd@unit.sg');
      await tester.enterText(find.byKey(const Key('password')), 'password1');
      await tester.tap(find.byKey(const Key('signInButton')));
      await tester.pumpAndSettle();
      verify(() => signIn(const EmailCredentials('cmd@unit.sg', 'password1')))
          .called(1);
      expect(find.text('Login Successful'), findsOneWidget);
    });

    testWidgets('wrong credentials show the source error text', (tester) async {
      when(() => signIn(any()))
          .thenAnswer((_) async => const Left(AuthFailure('x')));
      await pumpGate(tester);
      await tester.enterText(find.byKey(const Key('email')), 'cmd@unit.sg');
      await tester.enterText(find.byKey(const Key('password')), 'password1');
      await tester.tap(find.byKey(const Key('signInButton')));
      await tester.pumpAndSettle();
      expect(find.text('Wrong Email/Password or Both'), findsOneWidget);
    });

    testWidgets('forgot password opens its route', (tester) async {
      final recorder = await pumpGate(tester);
      await tester.tap(find.byKey(const Key('forgotPasswordButton')));
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.forgotPassword);
    });

    testWidgets('register page validates and switches back', (tester) async {
      await pumpGate(tester);
      await tester.tap(find.byKey(const Key('registerPageButton')));
      await tester.pumpAndSettle();
      expect(find.text('Sign Up!'), findsOneWidget);

      await tester.scrollUntilVisible(
          find.byKey(const Key('registerButton')), 300,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byKey(const Key('registerButton')));
      await tester.pumpAndSettle();
      expect(find.text('Details missing'), findsOneWidget);
      expect(find.text('Password needs to be stronger'), findsNothing);
      verifyNever(() => register(any()));

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('signInPageButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('signInPageButton')));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to camp!'), findsOneWidget);
    });
  });

  group('ForgotPasswordPage', () {
    Future<void> pumpReset(WidgetTester tester) => tester.pumpApp(
          Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => provider(),
                child: const ForgotPasswordPage(),
              ),
            ),
          ),
        );

    testWidgets('success shows the source dialog', (tester) async {
      await pumpReset(tester);
      await tester.enterText(
          find.byKey(const Key('reset-email')), 'cmd@unit.sg');
      await tester.tap(find.byKey(const Key('resetButton')));
      await tester.pumpAndSettle();
      verify(() => reset('cmd@unit.sg')).called(1);
      expect(find.text('Reset link has been sent to your Email account!'),
          findsOneWidget);
    });

    testWidgets('failure shows the Firebase message', (tester) async {
      when(() => reset(any()))
          .thenAnswer((_) async => const Left(AuthFailure('No user record')));
      await pumpReset(tester);
      await tester.enterText(find.byKey(const Key('reset-email')), 'x@y.z');
      await tester.tap(find.byKey(const Key('resetButton')));
      await tester.pumpAndSettle();
      expect(find.text('No user record'), findsOneWidget);
    });
  });
}
