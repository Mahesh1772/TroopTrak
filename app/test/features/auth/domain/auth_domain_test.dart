import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/phone_auth_event.dart';
import 'package:trooptrak_final_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/auth_usecases.dart';
import 'package:trooptrak_final_application/features/auth/domain/validators/auth_validators.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  group('AuthValidators (R20)', () {
    test('email', () {
      expect(AuthValidators.email(''), 'Email can not be empty');
      expect(AuthValidators.email(null), 'Email can not be empty');
      expect(AuthValidators.email('nope'), 'Invalid Email Address');
      expect(AuthValidators.email('a@b@c'), 'Invalid Email Address');
      expect(AuthValidators.email('cmd@unit.sg'), isNull);
      expect(AuthValidators.email('  cmd@unit.sg  '), isNull);
      expect(AuthValidators.email('cmd@localhost'), isNull);
    });

    test('password', () {
      expect(AuthValidators.password(''), 'Password can not be empty');
      expect(AuthValidators.password('1234567'),
          'Password should be at least 8 characters long');
      expect(AuthValidators.password('12345678'), isNull);
    });

    test('confirm password', () {
      expect(AuthValidators.confirmPassword('abc', 'abd'), isNotNull);
      expect(AuthValidators.confirmPassword(' abc ', 'abc'), isNull);
    });

    test('new password: the length rule first, then strength', () {
      expect(AuthValidators.newPassword(''), 'Password can not be empty');
      expect(AuthValidators.newPassword('1234567'),
          'Password should be at least 8 characters long');
      expect(AuthValidators.newPassword('password1'),
          'Password needs to be stronger');
      expect(AuthValidators.newPassword(' Trooper1! '), isNull);
    });

    test('repeated password', () {
      expect(AuthValidators.repeatedPassword('abc', 'abd'),
          'Make sure both Passwords match');
      expect(AuthValidators.repeatedPassword(null, 'abd'),
          'Make sure both Passwords match');
      expect(AuthValidators.repeatedPassword(' abc ', 'abc'), isNull);
    });

    test('commander name', () {
      expect(AuthValidators.commanderName('  '), 'You must have a name right');
      expect(AuthValidators.commanderName(null), 'You must have a name right');
      expect(AuthValidators.commanderName('12345'), 'Your name got number meh');
      expect(AuthValidators.commanderName(' Lim '), isNull);
      expect(AuthValidators.commanderName(' Tan Ah Kow '), isNull);
    });

    test('soldier name: empty, all-numeric, shorter than 5', () {
      expect(AuthValidators.soldierName(''), 'Must have a name right');
      expect(AuthValidators.soldierName('12345'), 'Name got number meh');
      expect(AuthValidators.soldierName('12.5'), 'Name got number meh');
      expect(AuthValidators.soldierName('Tan'), 'Brother, enter full name leh');
      expect(AuthValidators.soldierName('Tan Ah Kow'), isNull);
      expect(AuthValidators.soldierName('Tan 2nd'), isNull);
    });

    test('phone number and OTP', () {
      expect(AuthValidators.phoneNumber(''), isNotNull);
      expect(AuthValidators.phoneNumber('12ab'), isNotNull);
      expect(AuthValidators.phoneNumber('9123 4567'), isNull);
      expect(AuthValidators.otp('12345'), 'Enter 6 digit code');
      expect(AuthValidators.otp('12345a'), 'Enter 6 digit code');
      expect(AuthValidators.otp('123456'), isNull);
    });

    test('the OTP is complete only at exactly six digits', () {
      expect(AuthValidators.otpLength, 6);
      expect(AuthValidators.isOtpComplete(null), isFalse);
      expect(AuthValidators.isOtpComplete(''), isFalse);
      expect(AuthValidators.isOtpComplete('12345'), isFalse);
      expect(AuthValidators.isOtpComplete('1234567'), isFalse);
      expect(AuthValidators.isOtpComplete('12345a'), isFalse);
      expect(AuthValidators.isOtpComplete('12345 '), isFalse);
      expect(AuthValidators.isOtpComplete('123456'), isTrue);
    });
  });

  group('use cases', () {
    late _MockRepo repo;
    const user = AuthUser(uid: 'u1', email: 'cmd@unit.sg');

    setUp(() => repo = _MockRepo());

    test('SignInWithEmail validates then trims', () async {
      when(() => repo.signInWithEmail(any(), any()))
          .thenAnswer((_) async => const Right(user));
      expect(
          await SignInWithEmail(repo)(
              const EmailCredentials(' cmd@unit.sg ', ' password1 ')),
          const Right<Failure, AuthUser>(user));
      verify(() => repo.signInWithEmail('cmd@unit.sg', 'password1')).called(1);

      final bad =
          await SignInWithEmail(repo)(const EmailCredentials('x', 'password1'));
      expect(
          bad,
          const Left<Failure, AuthUser>(
              ValidationFailure('Invalid Email Address')));
    });

    test('SendPasswordReset trims the email', () async {
      when(() => repo.sendPasswordReset(any()))
          .thenAnswer((_) async => const Right(unit));
      await SendPasswordReset(repo)('  cmd@unit.sg ');
      verify(() => repo.sendPasswordReset('cmd@unit.sg')).called(1);
      expect((await SendPasswordReset(repo)('')).isLeft(), isTrue);
    });

    test('VerifyPhone streams repository events', () async {
      when(() =>
              repo.verifyPhone(any(), resendToken: any(named: 'resendToken')))
          .thenAnswer((_) => Stream.fromIterable(const [
                OtpSent('vid', resendToken: 7),
                OtpTimeout('vid'),
              ]));
      expect(
          await VerifyPhone(repo)(
                  const PhoneParams('+6591234567', resendToken: 7))
              .toList(),
          const [OtpSent('vid', resendToken: 7), OtpTimeout('vid')]);
      verify(() => repo.verifyPhone('+6591234567', resendToken: 7)).called(1);
    });

    test('VerifyOtp requires 6 digits', () async {
      when(() => repo.verifyOtp(any(), any()))
          .thenAnswer((_) async => const Right(user));
      expect((await VerifyOtp(repo)(const OtpParams('vid', '123'))).isLeft(),
          isTrue);
      expect(await VerifyOtp(repo)(const OtpParams('vid', '123456')),
          const Right<Failure, AuthUser>(user));
    });

    test('sign out and auth state delegate', () async {
      when(() => repo.signOut()).thenAnswer((_) async => const Right(unit));
      when(() => repo.authStateChanges()).thenAnswer((_) => Stream.value(user));
      when(() => repo.currentUser).thenReturn(user);

      await SignOut(repo)(const NoParams());
      verify(() => repo.signOut()).called(1);
      expect(await WatchAuthState(repo)().first, user);
      expect(WatchAuthState(repo).current, user);
    });
  });
}
