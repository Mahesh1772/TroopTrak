import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/widgets/brand_plate.dart';
import 'package:trooptrak_final_application/core/widgets/inline_error.dart';
import 'package:trooptrak_final_application/core/widgets/sticky_cta_bar.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/auth_usecases.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/register_commander.dart';
import 'package:trooptrak_final_application/features/auth/presentation/pages/commander_auth_gate.dart';
import 'package:trooptrak_final_application/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:trooptrak_final_application/features/auth/presentation/providers/commander_auth_provider.dart';
import 'package:trooptrak_final_application/features/auth/presentation/widgets/auth_header.dart';
import 'package:trooptrak_final_application/features/auth/presentation/widgets/password_checklist.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/pump_app.dart';

Finder _input(String key) => find.descendant(
    of: find.byKey(Key(key)), matching: find.byType(InputDecorator));

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

    testWidgets('sign in follows the theme instead of forcing dark',
        (tester) async {
      final mode = themeModes.currentValue!;
      await pumpGate(tester, mode: mode);
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.brightness,
          mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
      expect(tester.widget<Text>(find.text('Welcome to camp!')).style!.color,
          theme.colorScheme.onSurface);
    }, variant: themeModes);

    testWidgets('sign in puts labels above the fields and pins the buttons',
        (tester) async {
      await pumpGate(tester);
      for (final (label, key) in [
        ('Email ID', 'email'),
        ('Password', 'password'),
      ]) {
        expect(tester.getRect(find.text(label)).bottom,
            lessThan(tester.getRect(_input(key)).top),
            reason: label);
        expect(tester.getSize(_input(key)).height, 52, reason: label);
      }
      final button = tester.getRect(find.byKey(const Key('signInButton')));
      expect(button.left, 24);
      expect(button.right, 366);
      for (final key in ['signInButton', 'registerPageButton']) {
        expect(
            find.descendant(
                of: find.byType(StickyCtaBar), matching: find.byKey(Key(key))),
            findsOneWidget,
            reason: key);
      }
      expect(tester.getRect(find.byKey(const Key('registerPageButton'))).top,
          greaterThanOrEqualTo(button.bottom));
    });

    testWidgets('the forgot password link sits under the password field',
        (tester) async {
      await pumpGate(tester);
      final link =
          tester.getRect(find.byKey(const Key('forgotPasswordButton')));
      expect(link.top,
          greaterThanOrEqualTo(tester.getRect(_input('password')).bottom));
      expect(link.right, closeTo(366, 1));
      expect(find.text('Forgot Password? Aiyahhh'), findsOneWidget);
    });

    testWidgets('the password eye shows what was typed', (tester) async {
      await pumpGate(tester);
      bool hidden() => tester
          .widget<EditableText>(find.descendant(
              of: find.byKey(const Key('password')),
              matching: find.byType(EditableText)))
          .obscureText;
      expect(hidden(), isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(hidden(), isFalse);
    });

    testWidgets('validation errors are inline, in the legible red',
        (tester) async {
      final mode = themeModes.currentValue!;
      await pumpGate(tester, mode: mode);
      await tester.enterText(find.byKey(const Key('email')), 'nope');
      await tester.enterText(find.byKey(const Key('password')), '123');
      await tester.pumpAndSettle();
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      for (final message in [
        'Invalid Email Address',
        'Password should be at least 8 characters long',
      ]) {
        expect(
            find.descendant(
                of: find.byType(InlineError), matching: find.text(message)),
            findsOneWidget,
            reason: message);
        expect(tester.widget<Text>(find.text(message)).style!.color,
            palette.leaveText,
            reason: message);
      }
    }, variant: themeModes);

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

      final button = find.byKey(const Key('registerButton'));
      final pinned = tester.getRect(button);
      expect(pinned.bottom, lessThanOrEqualTo(tester.view.physicalSize.height));
      await tester.scrollUntilVisible(
          find.byKey(const Key('signInPageButton')), 300,
          scrollable: find.byType(Scrollable).first);
      expect(tester.getRect(button), pinned);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Details missing'), findsOneWidget);
      expect(find.text('Password needs to be stronger'), findsNothing);
      verifyNever(() => register(any()));
      for (final (label, key) in [
        ('Email:', 'register-email'),
        ('Enter password:', 'register-password'),
        ('Confirm password:', 'register-confirm'),
      ]) {
        await tester.ensureVisible(find.text(label));
        expect(tester.getRect(find.text(label)).bottom,
            lessThan(tester.getRect(_input(key)).top),
            reason: label);
      }

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('signInPageButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('signInPageButton')));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to camp!'), findsOneWidget);
    });
  });

  group('CommanderRegisterPage', () {
    late _MockWatch watch;

    setUp(() {
      watch = _MockWatch();
      when(() => watch()).thenAnswer((_) => const Stream.empty());
      when(() => watch.current).thenReturn(null);
    });

    Future<void> pumpRegister(WidgetTester tester,
        {ThemeMode mode = ThemeMode.dark}) async {
      final p = provider()..toggleMode();
      await tester.pumpApp(
        ChangeNotifierProvider.value(
          value: p,
          child: CommanderAuthGate(signedIn: (_) => const Text('HOME')),
        ),
        mode: mode,
        providers: [Provider<WatchAuthState>.value(value: watch)],
      );
    }

    testWidgets('follows the theme instead of forcing dark', (tester) async {
      final mode = themeModes.currentValue!;
      await pumpRegister(tester, mode: mode);
      final theme = Theme.of(tester.element(find.text('Sign Up!')));
      expect(theme.brightness,
          mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
      expect(tester.widget<Text>(find.text('Sign Up!')).style!.color,
          theme.colorScheme.onSurface);
    }, variant: themeModes);

    testWidgets('the heading sits left under the brand plate', (tester) async {
      await pumpRegister(tester);
      expect(find.text('Make your life easier, Register'), findsOneWidget);
      expect(tester.getRect(find.byType(BrandPlate)).bottom,
          lessThan(tester.getRect(find.text('Sign Up!')).top));
      expect(tester.getRect(find.text('Sign Up!')).left, lessThan(30));
    });

    testWidgets('the checklist turns green rule by rule', (tester) async {
      final mode = themeModes.currentValue!;
      final palette =
          mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;
      await pumpRegister(tester, mode: mode);
      final checklist = find.byType(PasswordChecklist);
      await tester.ensureVisible(checklist);
      await tester.pumpAndSettle();

      Iterable<Color?> colours() => tester
          .widgetList<Icon>(
              find.descendant(of: checklist, matching: find.byType(Icon)))
          .map((i) => i.color);
      expect(colours(), everyElement(palette.leaveText));
      expect(find.descendant(of: checklist, matching: find.text('1 number')),
          findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('register-password')), 'Trooper1!');
      await tester.pump();
      expect(colours(), everyElement(palette.successText));
      expect(
          find.descendant(
              of: checklist, matching: find.byIcon(Icons.check_circle_rounded)),
          findsNWidgets(5));

      await tester.enterText(find.byKey(const Key('register-password')), '1');
      await tester.pump();
      expect(colours().where((c) => c == palette.successText), hasLength(1));
    }, variant: themeModes);

    testWidgets('a mismatched confirmation shows the source message inline',
        (tester) async {
      await pumpRegister(tester);
      await tester.ensureVisible(find.byKey(const Key('register-confirm')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('register-password')), 'Trooper1!');
      await tester.enterText(find.byKey(const Key('register-confirm')), 'x');
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byType(InlineError),
              matching: find.text('Make sure both Passwords match')),
          findsOneWidget);
    });

    testWidgets('both password fields have an eye', (tester) async {
      await pumpRegister(tester);
      await tester.ensureVisible(find.byKey(const Key('register-confirm')));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Show password'), findsNWidgets(2));
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

    testWidgets('follows the theme and has a back arrow, a title and a label',
        (tester) async {
      final mode = themeModes.currentValue!;
      await tester.pumpApp(
        Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => provider(),
              child: const ForgotPasswordPage(),
            ),
          ),
        ),
        mode: mode,
      );
      final theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.brightness,
          mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(
          tester
              .widget<Text>(find.descendant(
                  of: find.byType(AuthHeader),
                  matching: find.text('Reset Password')))
              .style!
              .color,
          theme.colorScheme.onSurface);
      expect(find.text('Enter in your Email, a reset link will be sent to it'),
          findsOneWidget);
      expect(tester.getRect(find.text('Email ID')).bottom,
          lessThan(tester.getRect(_input('reset-email')).top));
    }, variant: themeModes);

    testWidgets('the button is pinned at the bottom with a 24 px inset',
        (tester) async {
      await pumpReset(tester);
      final button = tester.getRect(find.byKey(const Key('resetButton')));
      expect(button.left, 24);
      expect(button.right, 366);
      expect(button.bottom, greaterThan(750));
      expect(
          find.descendant(
              of: find.byType(StickyCtaBar),
              matching: find.byKey(const Key('resetButton'))),
          findsOneWidget);
    });

    testWidgets('the back arrow pops the page', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => provider(),
                child: const ForgotPasswordPage(),
              ),
            )),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordPage), findsNothing);
    });
  });
}
