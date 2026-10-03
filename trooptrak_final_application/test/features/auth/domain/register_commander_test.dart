import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/services/preferences_service.dart';
import 'package:trooptrak_final_application/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:trooptrak_final_application/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/register_commander.dart';
import 'package:trooptrak_final_application/features/auth/domain/validators/password_rules.dart';
import 'package:trooptrak_final_application/features/soldiers/data/datasources/soldier_remote_data_source.dart';
import 'package:trooptrak_final_application/features/soldiers/data/repositories/soldier_repository_impl.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/repositories/soldier_repository.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fake_clock.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockSoldiers extends Mock implements SoldierRepository {}

void main() {
  final clock = FixedClock(DateTime(2023, 7, 5, 9, 30));
  const strong = 'Passw0rd!x';
  final registration = CommanderRegistration(
    email: ' cmd@unit.sg ',
    password: strong,
    profile: buildSoldier(name: '  lee  wei ', id: '', rank: '2LT'),
  );

  group('PasswordRule', () {
    test('matches the source checklist', () {
      expect(PasswordRule.isStrong(strong), isTrue);
      expect(PasswordRule.isStrong('password'), isFalse);
      expect(PasswordRule.uppercase.passes('abc'), isFalse);
      expect(PasswordRule.lowercase.passes('ABab'), isFalse);
      expect(PasswordRule.lowercase.passes('abc'), isTrue);
      expect(PasswordRule.special.passes('abc!'), isTrue);
      expect(PasswordRule.special.passes('abc 1'), isFalse);
    });
  });

  group('with mocks', () {
    late _MockAuth auth;
    late _MockSoldiers soldiers;

    setUpAll(() => registerFallbackValue(buildSoldier()));
    setUp(() {
      auth = _MockAuth();
      soldiers = _MockSoldiers();
      when(() => soldiers.exists(any()))
          .thenAnswer((_) async => const Right(false));
      when(() => auth.registerWithEmail(any(), any()))
          .thenAnswer((_) async => const Right(AuthUser(uid: 'c1')));
      when(() => auth.updateDisplayName(any()))
          .thenAnswer((_) async => const Right(unit));
      when(() => soldiers.add(any(), createdAt: any(named: 'createdAt')))
          .thenAnswer((_) async => const Right(unit));
      when(() => auth.signOut(clearPreferences: any(named: 'clearPreferences')))
          .thenAnswer((_) async => const Right(unit));
    });

    test('runs the source sequence with a TitleCase name', () async {
      final result =
          await RegisterCommander(auth, soldiers, clock)(registration);
      expect(result, const Right<Failure, Unit>(unit));

      verifyInOrder([
        () => soldiers.exists('Lee Wei'),
        () => auth.registerWithEmail('cmd@unit.sg', strong),
        () => auth.updateDisplayName('Lee Wei'),
        () => soldiers.add(
            any(
                that: isA<Soldier>()
                    .having((s) => s.id, 'id', 'Lee Wei')
                    .having((s) => s.isInCamp, 'isInCamp', true)
                    .having((s) => s.points, 'points', 0)),
            createdAt: DateTime(2023, 7, 5, 9, 30)),
        () => auth.signOut(clearPreferences: false),
      ]);
    });

    test('a weak password stops before any call', () async {
      final weak = CommanderRegistration(
          email: 'cmd@unit.sg',
          password: 'password1',
          profile: registration.profile);
      expect(
          await RegisterCommander(auth, soldiers, clock)(weak),
          const Left<Failure, Unit>(
              ValidationFailure('Password needs to be stronger')));
      verifyZeroInteractions(auth);
    });

    test('an existing name is refused before the account is created (K13)',
        () async {
      when(() => soldiers.exists(any()))
          .thenAnswer((_) async => const Right(true));
      final result =
          await RegisterCommander(auth, soldiers, clock)(registration);
      expect(result.isLeft(), isTrue);
      verifyNever(() => auth.registerWithEmail(any(), any()));
    });

    test('an auth failure stops before writing the soldier', () async {
      when(() => auth.registerWithEmail(any(), any())).thenAnswer((_) async =>
          const Left(AuthFailure('in use', code: 'email-already-in-use')));
      expect(
          (await RegisterCommander(auth, soldiers, clock)(registration))
              .isLeft(),
          isTrue);
      verifyNever(
          () => soldiers.add(any(), createdAt: any(named: 'createdAt')));
    });
  });

  test('end to end over fake Firestore and auth: doc, attendance, signed out',
      () async {
    SharedPreferences.setMockInitialValues({'onBoard': 2});
    final prefs = await PreferencesService.create();
    final db = FakeFirebaseFirestore();
    final firebaseAuth = MockFirebaseAuth();
    final useCase = RegisterCommander(
      AuthRepositoryImpl(FirebaseAuthDataSource(firebaseAuth), prefs),
      SoldierRepositoryImpl(SoldierRemoteDataSource(db)),
      clock,
    );

    expect(await useCase(registration), const Right<Failure, Unit>(unit));

    final doc = await db.collection('Users').doc('Lee Wei').get();
    expect(doc.data()!['rank'], '2LT');
    expect(doc.data()!['currentAttendance'], 'Inside Camp');
    final att = await db
        .collection('Users')
        .doc('Lee Wei')
        .collection('Attendance')
        .doc('2023-07-05 09:30:00')
        .get();
    expect(att.data()!['isInsideCamp'], isTrue);
    expect(firebaseAuth.currentUser, isNull);
    expect(prefs.onBoard, 2);
  });
}
