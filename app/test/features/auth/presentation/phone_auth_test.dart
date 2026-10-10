import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/phone_auth_event.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/auth_usecases.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/soldier_entry.dart';
import 'package:trooptrak_final_application/features/auth/presentation/pages/phone_entry_page.dart';
import 'package:trooptrak_final_application/features/auth/presentation/pages/soldier_welcome_page.dart';
import 'package:trooptrak_final_application/features/auth/presentation/providers/phone_auth_provider.dart';

import '../../../helpers/pump_app.dart';

class _MockVerifyPhone extends Mock implements VerifyPhone {}

class _MockVerifyOtp extends Mock implements VerifyOtp {}

class _MockComplete extends Mock implements CompleteSoldierSignIn {}

class _MockResolve extends Mock implements ResolveSoldierEntry {}

void main() {
  late _MockVerifyPhone verifyPhone;
  late _MockVerifyOtp verifyOtp;
  late _MockComplete complete;
  late StreamController<PhoneAuthEvent> events;
  const user = AuthUser(uid: 's1');

  setUpAll(() {
    registerFallbackValue(const PhoneParams(''));
    registerFallbackValue(const OtpParams('', ''));
    registerFallbackValue(user);
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    verifyPhone = _MockVerifyPhone();
    verifyOtp = _MockVerifyOtp();
    complete = _MockComplete();
    events = StreamController<PhoneAuthEvent>.broadcast();
    when(() => verifyPhone(any())).thenAnswer((_) => events.stream);
    when(() => verifyOtp(any())).thenAnswer((_) async => const Right(user));
    when(() => complete(any()))
        .thenAnswer((_) async => const Right(SoldierEntry.home));
  });

  tearDown(() => events.close());

  PhoneAuthProvider provider() => PhoneAuthProvider(
      verifyPhone: verifyPhone, verifyOtp: verifyOtp, completeSignIn: complete);

  group('PhoneAuthProvider', () {
    test('invalid number fails without calling Firebase', () async {
      final p = provider();
      expect(await p.sendCode('65', 'abc'), PhoneOutcome.failed);
      expect(p.error, 'Enter a valid phone number');
      verifyNever(() => verifyPhone(any()));
    });

    test('code sent stores the verification id and E.164 number', () async {
      final p = provider();
      final outcome = p.sendCode('65', '9123 4567');
      events.add(const OtpSent('vid', resendToken: 3));
      expect(await outcome, PhoneOutcome.codeSent);
      expect(p.verificationId, 'vid');
      expect(p.phoneNumber, '+6591234567');
      verify(() => verifyPhone(const PhoneParams('+6591234567'))).called(1);
    });

    test('verification error fails with its message', () async {
      final p = provider();
      final outcome = p.sendCode('65', '91234567');
      events.add(const PhoneVerificationError(AuthFailure('Quota exceeded')));
      expect(await outcome, PhoneOutcome.failed);
      expect(p.error, 'Quota exceeded');
      expect(p.busy, isFalse);
    });

    test('auto verification before any code routes immediately', () async {
      when(() => complete(any()))
          .thenAnswer((_) async => const Right(SoldierEntry.profileCapture));
      final p = provider();
      final outcome = p.sendCode('65', '91234567');
      events.add(const PhoneAutoVerified(user));
      expect(await outcome, PhoneOutcome.profileCapture);
    });

    test('auto verification after the code is exposed once', () async {
      final p = provider();
      final outcome = p.sendCode('65', '91234567');
      events.add(const OtpSent('vid'));
      await outcome;
      events.add(const PhoneAutoVerified(user));
      await Future<void>.delayed(Duration.zero);
      expect(p.takeAutoOutcome(), PhoneOutcome.home);
      expect(p.takeAutoOutcome(), isNull);
    });

    test('timeout keeps the id for manual entry', () async {
      final p = provider();
      final outcome = p.sendCode('65', '91234567');
      events.add(const OtpTimeout('vid-t'));
      events.add(const OtpSent('vid-t'));
      expect(await outcome, PhoneOutcome.codeSent);
      expect(p.verificationId, 'vid-t');
    });

    test('OTP: wrong code fails, right code completes sign-in', () async {
      final p = provider();
      final sent = p.sendCode('65', '91234567');
      events.add(const OtpSent('vid'));
      await sent;

      when(() => verifyOtp(any())).thenAnswer(
          (_) async => const Left(AuthFailure('The OTP entered is invalid.')));
      expect(await p.submitOtp('000000'), PhoneOutcome.failed);
      expect(p.error, 'The OTP entered is invalid.');

      when(() => verifyOtp(any())).thenAnswer((_) async => const Right(user));
      expect(await p.submitOtp('123456'), PhoneOutcome.home);
      verify(() => verifyOtp(const OtpParams('vid', '123456'))).called(1);
    });

    test('OTP before a code was sent fails', () async {
      expect(await provider().submitOtp('123456'), PhoneOutcome.failed);
    });

    test('resend reuses the number and the resend token', () async {
      final p = provider();
      final sent = p.sendCode('65', '91234567');
      events.add(const OtpSent('vid', resendToken: 9));
      await sent;
      final again = StreamController<PhoneAuthEvent>.broadcast();
      when(() => verifyPhone(any())).thenAnswer((_) => again.stream);
      final resent = p.resend();
      again.add(const OtpSent('vid-2', resendToken: 10));
      expect(await resent, PhoneOutcome.codeSent);
      verify(() =>
              verifyPhone(const PhoneParams('+6591234567', resendToken: 9)))
          .called(1);
      await again.close();
    });
  });

  group('pages', () {
    for (final (entry, route) in [
      (SoldierEntry.home, AppRoutes.soldierHome),
      (SoldierEntry.profileCapture, AppRoutes.profileCapture),
      (SoldierEntry.phoneEntry, AppRoutes.phoneEntry),
    ]) {
      testWidgets('welcome GET STARTED with $entry opens $route (R19)',
          (tester) async {
        final resolve = _MockResolve();
        when(() => resolve(any())).thenAnswer((_) async => Right(entry));
        final recorder = RouteRecorder();
        await tester.pumpApp(
          const SoldierWelcomePage(),
          providers: [Provider<ResolveSoldierEntry>.value(value: resolve)],
          observers: [recorder],
        );
        expect(find.text('Time to book in 😄'), findsOneWidget);
        await tester.tap(find.byKey(const Key('getStarted')));
        await tester.pumpAndSettle();
        expect(recorder.names.last, route);
      });
    }

    Future<RouteRecorder> pumpPhone(WidgetTester tester, PhoneAuthProvider p,
        {ThemeMode mode = ThemeMode.dark}) async {
      final recorder = RouteRecorder();
      await tester.pumpApp(
        ChangeNotifierProvider.value(value: p, child: const PhoneEntryPage()),
        mode: mode,
        observers: [recorder],
      );
      return recorder;
    }

    testWidgets('phone entry defaults to Singapore +65', (tester) async {
      await pumpPhone(tester, provider(), mode: themeModes.currentValue!);
      expect(find.textContaining('+65'), findsOneWidget);
      expect(find.text('Enter Phone Number'), findsOneWidget);
    }, variant: themeModes);

    testWidgets('invalid number shows an error', (tester) async {
      await pumpPhone(tester, provider());
      await tester.enterText(find.byKey(const Key('phone')), '12');
      await tester.tap(find.byKey(const Key('sendCode')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsOneWidget);
    });

    Finder otpField() => find.byType(EditableText).last;

    Future<void> toOtpPage(WidgetTester tester, PhoneAuthProvider p) async {
      await tester.enterText(find.byKey(const Key('phone')), '91234567');
      await tester.tap(find.byKey(const Key('sendCode')));
      await tester.pump();
      events.add(const OtpSent('vid'));
      await tester.pumpAndSettle();
      expect(find.text('User Verification'), findsOneWidget);
    }

    testWidgets('wrong OTP shows the error', (tester) async {
      final p = provider();
      await pumpPhone(tester, p);
      await toOtpPage(tester, p);
      when(() => verifyOtp(any())).thenAnswer(
          (_) async => const Left(AuthFailure('The OTP entered is invalid.')));
      await tester.enterText(otpField(), '000000');
      await tester.pumpAndSettle();
      expect(find.text('The OTP entered is invalid.'), findsOneWidget);
    });

    testWidgets('existing soldier goes to the soldier home', (tester) async {
      final p = provider();
      final recorder = await pumpPhone(tester, p);
      await toOtpPage(tester, p);
      await tester.enterText(otpField(), '123456');
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.soldierHome);
    });

    testWidgets('new soldier goes to profile capture', (tester) async {
      when(() => complete(any()))
          .thenAnswer((_) async => const Right(SoldierEntry.profileCapture));
      final p = provider();
      final recorder = await pumpPhone(tester, p);
      await toOtpPage(tester, p);
      await tester.tap(find.byKey(const Key('verify')));
      await tester.pumpAndSettle();
      expect(find.text('Enter 6 digit code'), findsOneWidget);
      await tester.enterText(otpField(), '123456');
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.profileCapture);
    });
  });
}
