import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/services/preferences_service.dart';
import 'package:trooptrak_final_application/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:trooptrak_final_application/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/phone_auth_event.dart';

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockCredential extends Mock implements UserCredential {}

class _FakePhoneCredential extends Fake implements PhoneAuthCredential {}

void main() {
  late PreferencesService prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'onBoard': 2, 'is_signedin': true});
    prefs = await PreferencesService.create();
  });

  AuthRepositoryImpl repoWith(FirebaseAuth auth) =>
      AuthRepositoryImpl(FirebaseAuthDataSource(auth), prefs);

  group('email flows (firebase_auth_mocks)', () {
    late MockFirebaseAuth auth;

    setUp(() {
      auth = MockFirebaseAuth(
          mockUser: MockUser(
              uid: 'c1', email: 'cmd@unit.sg', displayName: 'Lee Wei'));
    });

    test('sign in returns the user and updates auth state', () async {
      final repo = repoWith(auth);
      final states =
          expectLater(repo.authStateChanges(), emitsThrough(isA<AuthUser>()));
      final result = await repo.signInWithEmail('cmd@unit.sg', 'password1');
      expect(result.getOrElse(() => throw 'x').uid, 'c1');
      await states;
      expect(repo.currentUser?.email, 'cmd@unit.sg');
    });

    test('register creates the user', () async {
      final result =
          await repoWith(auth).registerWithEmail('new@unit.sg', 'password1');
      expect(result.isRight(), isTrue);
    });

    test('auth errors map to AuthFailure with the Firebase message', () async {
      final failing = _MockAuth();
      when(() => failing.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(
              code: 'wrong-password', message: 'The password is invalid.'));
      expect(
          await repoWith(failing).signInWithEmail('cmd@unit.sg', 'password1'),
          const Left<Failure, AuthUser>(
              AuthFailure('The password is invalid.', code: 'wrong-password')));
    });

    test('deleteAccount removes the signed-in user; lastSignInAt is mapped',
        () async {
      final signedInAt = DateTime(2023, 7, 5, 9);
      final signedIn = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
              uid: 'c1',
              metadata: UserMetadata(0, signedInAt.millisecondsSinceEpoch)));
      final repo = repoWith(signedIn);
      expect(
          repo.currentUser?.lastSignInAt?.isAtSameMomentAs(signedInAt), isTrue);
      expect(await repo.deleteAccount(), const Right<Failure, Unit>(unit));
      expect((await repoWith(auth).deleteAccount()).isLeft(), isTrue);
    });

    test('update display name needs a signed-in user', () async {
      final repo = repoWith(auth);
      expect((await repo.updateDisplayName('Tan')).isLeft(), isTrue);
      await repo.signInWithEmail('cmd@unit.sg', 'password1');
      expect(await repo.updateDisplayName('Tan Ah Kow'),
          const Right<Failure, Unit>(unit));
      expect(auth.currentUser!.displayName, 'Tan Ah Kow');
    });

    test('sign out signs out and clears every preference (D4)', () async {
      final repo = repoWith(auth);
      await repo.signInWithEmail('cmd@unit.sg', 'password1');
      expect(await repo.signOut(), const Right<Failure, Unit>(unit));
      expect(auth.currentUser, isNull);
      expect(prefs.onBoard, isNull);
      expect(prefs.isSignedIn, isFalse);
    });

    test('soldier signed-in flag reads and writes is_signedin', () async {
      SharedPreferences.setMockInitialValues({});
      prefs = await PreferencesService.create();
      final repo = repoWith(auth);
      expect(repo.isSoldierSignedIn, isFalse);
      await repo.markSoldierSignedIn();
      expect(repo.isSoldierSignedIn, isTrue);
    });
  });

  test('password reset is sent with the given email', () async {
    final auth = _MockAuth();
    when(() => auth.sendPasswordResetEmail(email: any(named: 'email')))
        .thenAnswer((_) async {});
    expect(await repoWith(auth).sendPasswordReset('cmd@unit.sg'),
        const Right<Failure, Unit>(unit));
    verify(() => auth.sendPasswordResetEmail(email: 'cmd@unit.sg')).called(1);
  });

  group('phone flow', () {
    late _MockAuth auth;

    setUpAll(() {
      registerFallbackValue(_FakePhoneCredential());
      registerFallbackValue(Duration.zero);
      registerFallbackValue((PhoneAuthCredential _) {});
      registerFallbackValue((FirebaseAuthException _) {});
      registerFallbackValue((String _, int? __) {});
      registerFallbackValue((String _) {});
    });
    setUp(() => auth = _MockAuth());

    void stubVerify(
        void Function(
          PhoneVerificationCompleted completed,
          PhoneVerificationFailed failed,
          PhoneCodeSent sent,
          PhoneCodeAutoRetrievalTimeout timeout,
        ) drive) {
      when(() => auth.verifyPhoneNumber(
            phoneNumber: any(named: 'phoneNumber'),
            timeout: any(named: 'timeout'),
            forceResendingToken: any(named: 'forceResendingToken'),
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          )).thenAnswer((inv) async {
        final args = inv.namedArguments;
        drive(
          args[#verificationCompleted] as PhoneVerificationCompleted,
          args[#verificationFailed] as PhoneVerificationFailed,
          args[#codeSent] as PhoneCodeSent,
          args[#codeAutoRetrievalTimeout] as PhoneCodeAutoRetrievalTimeout,
        );
      });
    }

    test('emits code sent then timeout, in order, and passes the resend token',
        () async {
      stubVerify((_, __, sent, timeout) {
        sent('vid-1', 42);
        timeout('vid-1');
      });
      final events = await repoWith(auth)
          .verifyPhone('+6591234567', resendToken: 41)
          .toList();
      expect(events,
          const [OtpSent('vid-1', resendToken: 42), OtpTimeout('vid-1')]);
      verify(() => auth.verifyPhoneNumber(
            phoneNumber: '+6591234567',
            timeout: const Duration(seconds: 60),
            forceResendingToken: 41,
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          )).called(1);
    });

    test('verification failure becomes a failed event and closes', () async {
      stubVerify((_, failed, __, ___) => failed(FirebaseAuthException(
          code: 'invalid-phone-number', message: 'Bad number')));
      final events = await repoWith(auth).verifyPhone('+65').toList();
      expect(events, const [
        PhoneVerificationError(
            AuthFailure('Bad number', code: 'invalid-phone-number'))
      ]);
    });

    test('auto verification signs in and emits the user', () async {
      final credential = _MockCredential();
      when(() => credential.user)
          .thenReturn(MockUser(uid: 's1', phoneNumber: '+6591234567'));
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => credential);
      stubVerify((completed, _, __, ___) => completed(_FakePhoneCredential()));

      final events = await repoWith(auth).verifyPhone('+6591234567').toList();
      expect(events, const [
        PhoneAutoVerified(AuthUser(uid: 's1', phoneNumber: '+6591234567'))
      ]);
    });

    test('verifyOtp signs in with the credential; bad code is an AuthFailure',
        () async {
      final credential = _MockCredential();
      when(() => credential.user).thenReturn(MockUser(uid: 's1'));
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => credential);
      expect(
          (await repoWith(auth).verifyOtp('vid', '123456'))
              .getOrElse(() => throw 'x')
              .uid,
          's1');

      when(() => auth.signInWithCredential(any()))
          .thenThrow(FirebaseAuthException(code: 'invalid-verification-code'));
      final bad = await repoWith(auth).verifyOtp('vid', '000000');
      expect(
          bad,
          const Left<Failure, AuthUser>(AuthFailure(
              'The OTP entered is invalid.',
              code: 'invalid-verification-code')));
    });
  });
}
