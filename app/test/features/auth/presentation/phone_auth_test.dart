import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/router/app_routes.dart';
import 'package:trooptrak_final_application/core/theme/app_palette.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/core/widgets/primary_button.dart';
import 'package:trooptrak_final_application/core/widgets/sticky_cta_bar.dart';
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
    test('the number is shown back as typed, with the dial code', () async {
      final p = provider();
      expect(p.displayNumber, isNull);
      final outcome = p.sendCode('65', '  9865   3214 ');
      events.add(const OtpSent('vid'));
      await outcome;
      expect(p.displayNumber, '+65 9865 3214');
      expect(p.phoneNumber, '+6598653214');
    });

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

    group('phone entry layout', () {
      testWidgets('the prefix chip reads SG +65 inside the 58 px field',
          (tester) async {
        await pumpPhone(tester, provider());
        final chip = find.byKey(const Key('country'));
        expect(find.descendant(of: chip, matching: find.text('SG')),
            findsOneWidget);
        expect(find.descendant(of: chip, matching: find.text('+65')),
            findsOneWidget);
        final field = tester.getRect(find.byKey(const Key('phone')));
        expect(field.height, 58);
        final pill = tester
            .getRect(find.descendant(of: chip, matching: find.byType(InkWell)));
        expect(pill.height, 44);
        expect(pill.left - field.left, closeTo(6, 0.5));
        expect(field.center.dy, closeTo(pill.center.dy, 0.5));
      });

      testWidgets('the typed number is centred in the field', (tester) async {
        await pumpPhone(tester, provider());
        await tester.enterText(find.byKey(const Key('phone')), '9865 3214');
        await tester.pump();
        final field = tester.getRect(find.byKey(const Key('phone')));
        final text = tester.getRect(find.descendant(
            of: find.byKey(const Key('phone')),
            matching: find.byType(EditableText)));
        expect(text.center.dy, closeTo(field.center.dy, 1.5));
      });

      testWidgets('the label sits above the field and the example under it',
          (tester) async {
        await pumpPhone(tester, provider());
        final label = tester.getRect(find.text('Phone Number'));
        final field = tester.getRect(find.byKey(const Key('phone')));
        final example = tester.getRect(find.text('Example: 9865 3214'));
        expect(label.bottom, lessThanOrEqualTo(field.top));
        expect(example.top, greaterThanOrEqualTo(field.bottom));
      });

      testWidgets('the typed number is large and in tabular figures',
          (tester) async {
        await pumpPhone(tester, provider());
        final style = tester
            .widget<EditableText>(find.descendant(
                of: find.byKey(const Key('phone')),
                matching: find.byType(EditableText)))
            .style;
        expect(style.fontSize, 21);
        expect(
            style.fontFeatures, contains(const FontFeature.tabularFigures()));
        expect(style.letterSpacing, closeTo(21 * 0.06, 0.001));
      });

      testWidgets('the button is pinned to the bottom with a 24 px inset',
          (tester) async {
        await pumpPhone(tester, provider());
        final button = tester.getRect(find.byKey(const Key('sendCode')));
        expect(button.left, 24);
        expect(button.right, 366);
        expect(button.height, 50);
        expect(button.bottom, greaterThan(750));
        expect(
            find.descendant(
                of: find.byType(StickyCtaBar),
                matching: find.byKey(const Key('sendCode'))),
            findsOneWidget);
      });

      testWidgets('follows the theme instead of forcing dark', (tester) async {
        final mode = themeModes.currentValue!;
        await pumpPhone(tester, provider(), mode: mode);
        final theme = Theme.of(tester.element(find.byType(Scaffold)));
        expect(theme.brightness,
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
        expect(
            tester.widget<Text>(find.text('Enter Phone Number')).style!.color,
            theme.colorScheme.onSurface);
      }, variant: themeModes);

      testWidgets('the button shows a loader while the code is requested',
          (tester) async {
        await pumpPhone(tester, provider());
        await tester.enterText(find.byKey(const Key('phone')), '91234567');
        await tester.tap(find.byKey(const Key('sendCode')));
        await tester.pump();
        expect(
            tester
                .widget<PrimaryButton>(find.byKey(const Key('sendCode')))
                .loading,
            isTrue);
        events.add(const OtpSent('vid'));
        await tester.pumpAndSettle();
      });
    });

    testWidgets('invalid number shows an error', (tester) async {
      await pumpPhone(tester, provider());
      await tester.enterText(find.byKey(const Key('phone')), '12');
      await tester.tap(find.byKey(const Key('sendCode')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsOneWidget);
    });

    Finder otpField() => find.byType(EditableText).last;

    Finder boxes() => find.descendant(
        of: find.byKey(const Key('otp')),
        matching: find.byType(AnimatedContainer));

    List<BoxDecoration> boxDecorations(WidgetTester tester) => tester
        .widgetList<AnimatedContainer>(boxes())
        .map((c) => c.decoration! as BoxDecoration)
        .toList();

    List<BorderSide> boxBorders(WidgetTester tester) =>
        boxDecorations(tester).map((d) => (d.border! as Border).top).toList();

    List<Rect> boxRects(WidgetTester tester) => [
          for (var i = 0; i < 6; i++) tester.getRect(boxes().at(i)),
        ];

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
      expect(boxBorders(tester).map((b) => b.color).toSet(),
          {AppPalette.dark.danger});
    });

    testWidgets('editing a rejected code clears the red boxes', (tester) async {
      final p = provider();
      await pumpPhone(tester, p);
      await toOtpPage(tester, p);
      when(() => verifyOtp(any())).thenAnswer(
          (_) async => const Left(AuthFailure('The OTP entered is invalid.')));
      await tester.enterText(otpField(), '000000');
      await tester.pumpAndSettle();
      await tester.enterText(otpField(), '00000');
      await tester.pump(const Duration(seconds: 1));
      expect(boxBorders(tester).map((b) => b.color),
          isNot(contains(AppPalette.dark.danger)));
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
      verifyNever(() => verifyOtp(any()));
      expect(find.text('Enter 6 digit code'), findsNothing);
      await tester.enterText(otpField(), '123456');
      await tester.pumpAndSettle();
      expect(recorder.names.last, AppRoutes.profileCapture);
    });

    group('OTP page', () {
      Future<PhoneAuthProvider> pumpOtp(WidgetTester tester,
          {ThemeMode mode = ThemeMode.dark}) async {
        final p = provider();
        await pumpPhone(tester, p, mode: mode);
        await toOtpPage(tester, p);
        return p;
      }

      PrimaryButton verifyButton(WidgetTester tester) =>
          tester.widget<PrimaryButton>(find.byKey(const Key('verify')));

      testWidgets('says Enter OTP Received, not Recieved', (tester) async {
        await pumpOtp(tester);
        expect(find.textContaining('Enter OTP Received.', findRichText: true),
            findsOneWidget);
        expect(
            find.textContaining('Recieved', findRichText: true), findsNothing);
        expect(
            find.textContaining('recieve', findRichText: true), findsNothing);
        expect(find.text('Did not receive OTP?'), findsOneWidget);
        expect(find.text('Resend New OTP'), findsOneWidget);
      });

      testWidgets('shows the number the code was sent to', (tester) async {
        await pumpOtp(tester);
        expect(
            find.textContaining('We sent a 6-digit code to ',
                findRichText: true),
            findsOneWidget);
        expect(find.textContaining('+65 91234567', findRichText: true),
            findsOneWidget);
      });

      testWidgets('VERIFY stays disabled until six digits are in',
          (tester) async {
        await pumpOtp(tester);
        expect(verifyButton(tester).onPressed, isNull);
        for (final partial in ['1', '12', '1234', '12345']) {
          await tester.enterText(otpField(), partial);
          await tester.pump();
          expect(verifyButton(tester).onPressed, isNull, reason: partial);
        }
        await tester.enterText(otpField(), '123456');
        await tester.pump();
        expect(verifyButton(tester).onPressed, isNotNull);
      });

      testWidgets('VERIFY goes back to disabled when a digit is deleted',
          (tester) async {
        when(() => verifyOtp(any())).thenAnswer((_) async =>
            const Left(AuthFailure('The OTP entered is invalid.')));
        await pumpOtp(tester);
        await tester.enterText(otpField(), '123456');
        await tester.pumpAndSettle();
        await tester.enterText(otpField(), '12345');
        await tester.pump();
        expect(verifyButton(tester).onPressed, isNull);
      });

      testWidgets('the enabled VERIFY submits the code again', (tester) async {
        when(() => verifyOtp(any())).thenAnswer((_) async =>
            const Left(AuthFailure('The OTP entered is invalid.')));
        await pumpOtp(tester);
        await tester.enterText(otpField(), '123456');
        await tester.pumpAndSettle();
        ScaffoldMessenger.of(tester.element(find.byKey(const Key('verify'))))
            .hideCurrentSnackBar();
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('verify')));
        await tester.pumpAndSettle();
        verify(() => verifyOtp(const OtpParams('vid', '123456'))).called(2);
      });

      testWidgets('letters are not accepted', (tester) async {
        await pumpOtp(tester);
        await tester.enterText(otpField(), '12ab34');
        await tester.pump();
        expect(verifyButton(tester).onPressed, isNull);
        expect(find.text('a'), findsNothing);
      });

      testWidgets('six equal boxes share the row between the 24 px insets',
          (tester) async {
        await pumpOtp(tester);
        final rects = boxRects(tester);
        expect(rects, hasLength(6));
        expect(rects.first.left, closeTo(24, 0.5));
        expect(rects.last.right, closeTo(366, 0.5));
        for (var i = 0; i < 6; i++) {
          expect(rects[i].height, 60);
          expect(rects[i].width, closeTo(rects.first.width, 0.01));
          if (i > 0) {
            expect(rects[i].left - rects[i - 1].right, closeTo(8, 0.01));
          }
        }
      });

      testWidgets('box borders: rest, accent on the next box, filled',
          (tester) async {
        final mode = themeModes.currentValue!;
        await pumpOtp(tester, mode: mode);
        final palette =
            mode == ThemeMode.dark ? AppPalette.dark : AppPalette.light;

        await tester.tap(find.byKey(const Key('otp')));
        await tester.pump();
        await tester.enterText(otpField(), '48');
        await tester.pump(const Duration(seconds: 1));
        final borders = boxBorders(tester);
        expect(borders[0].color, palette.line);
        expect(borders[1].color, palette.line);
        expect(borders[2].color, palette.accent);
        expect(borders[2].width, 2);
        expect(borders[3].color, palette.line);
        expect(borders[3].width, 1);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
        for (final box in boxDecorations(tester)) {
          expect(box.color, palette.cardElevated);
          expect((box.borderRadius! as BorderRadius).topLeft.x, 14);
        }
      }, variant: themeModes);

      testWidgets('digits are tabular 28 px figures', (tester) async {
        await pumpOtp(tester);
        await tester.enterText(otpField(), '4');
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        final style = tester
            .widget<Text>(
                find.descendant(of: boxes().first, matching: find.text('4')))
            .style!;
        expect(style.fontSize, 28);
        expect(
            style.fontFeatures, contains(const FontFeature.tabularFigures()));
        expect(style.color, AppPalette.dark.onCard);
      });

      testWidgets('VERIFY is pinned to the bottom with a 24 px inset',
          (tester) async {
        await pumpOtp(tester);
        final button = tester.getRect(find.byKey(const Key('verify')));
        expect(button.left, 24);
        expect(button.right, 366);
        expect(button.bottom, greaterThan(750));
        expect(
            find.descendant(
                of: find.byType(StickyCtaBar),
                matching: find.byKey(const Key('verify'))),
            findsOneWidget);
      });

      testWidgets('follows the theme instead of forcing dark', (tester) async {
        final mode = themeModes.currentValue!;
        await pumpOtp(tester, mode: mode);
        final theme = Theme.of(tester.element(find.byKey(const Key('otp'))));
        expect(theme.brightness,
            mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
        expect(tester.widget<Text>(find.text('User Verification')).style!.color,
            theme.colorScheme.onSurface);
      }, variant: themeModes);

      testWidgets('the back arrow returns to phone entry', (tester) async {
        await pumpOtp(tester);
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Enter Phone Number'), findsOneWidget);
        expect(find.text('User Verification'), findsNothing);
      });

      testWidgets('resend asks for a new code and confirms it', (tester) async {
        await pumpOtp(tester);
        clearInteractions(verifyPhone);
        await tester.tap(find.byKey(const Key('resend')));
        await tester.pump();
        events.add(const OtpSent('vid-2', resendToken: 2));
        await tester.pumpAndSettle();
        verify(() => verifyPhone(any())).called(1);
        expect(find.text('A new OTP has been sent.'), findsOneWidget);
      });

      testWidgets('a failed resend shows its error', (tester) async {
        await pumpOtp(tester);
        await tester.tap(find.byKey(const Key('resend')));
        await tester.pump();
        events.add(const PhoneVerificationError(AuthFailure('Quota exceeded')));
        await tester.pumpAndSettle();
        expect(find.text('Quota exceeded'), findsOneWidget);
      });
    });
  });
}
