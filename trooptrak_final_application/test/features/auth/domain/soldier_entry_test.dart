import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/soldier_entry.dart';
import 'package:trooptrak_final_application/features/enlistment/data/datasources/men_remote_data_source.dart';
import 'package:trooptrak_final_application/features/enlistment/data/repositories/men_repository_impl.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/repositories/men_repository.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/usecases/men_usecases.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockMen extends Mock implements MenRepository {}

void main() {
  late _MockAuth auth;
  late _MockMen men;
  const user = AuthUser(uid: 's1');

  setUp(() {
    auth = _MockAuth();
    men = _MockMen();
    when(() => auth.markSoldierSignedIn())
        .thenAnswer((_) async => const Right(unit));
  });

  group('ResolveSoldierEntry (R19)', () {
    test('no Firebase user goes to phone entry', () async {
      when(() => auth.currentUser).thenReturn(null);
      expect(await ResolveSoldierEntry(auth, men)(const NoParams()),
          const Right<Failure, SoldierEntry>(SoldierEntry.phoneEntry));
      verifyZeroInteractions(men);
    });

    test('signed in with a Men profile goes home', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => auth.isSoldierSignedIn).thenReturn(true);
      when(() => men.exists('s1')).thenAnswer((_) async => const Right(true));
      expect(await ResolveSoldierEntry(auth, men)(const NoParams()),
          const Right<Failure, SoldierEntry>(SoldierEntry.home));
    });

    test('user without a profile goes to capture', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => auth.isSoldierSignedIn).thenReturn(true);
      when(() => men.exists('s1')).thenAnswer((_) async => const Right(false));
      expect(await ResolveSoldierEntry(auth, men)(const NoParams()),
          const Right<Failure, SoldierEntry>(SoldierEntry.profileCapture));
    });

    test('profile but no is_signedin flag goes to phone entry', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => auth.isSoldierSignedIn).thenReturn(false);
      when(() => men.exists('s1')).thenAnswer((_) async => const Right(true));
      expect(await ResolveSoldierEntry(auth, men)(const NoParams()),
          const Right<Failure, SoldierEntry>(SoldierEntry.phoneEntry));
    });
  });

  group('CompleteSoldierSignIn', () {
    test('existing profile marks signed in and goes home', () async {
      when(() => men.exists('s1')).thenAnswer((_) async => const Right(true));
      expect(await CompleteSoldierSignIn(auth, men)(user),
          const Right<Failure, SoldierEntry>(SoldierEntry.home));
      verify(() => auth.markSoldierSignedIn()).called(1);
    });

    test('new soldier goes to capture without marking signed in', () async {
      when(() => men.exists('s1')).thenAnswer((_) async => const Right(false));
      expect(await CompleteSoldierSignIn(auth, men)(user),
          const Right<Failure, SoldierEntry>(SoldierEntry.profileCapture));
      verifyNever(() => auth.markSoldierSignedIn());
    });

    test('lookup failure is passed through', () async {
      when(() => men.exists('s1'))
          .thenAnswer((_) async => const Left(ServerFailure('down')));
      expect(await CompleteSoldierSignIn(auth, men)(user),
          const Left<Failure, SoldierEntry>(ServerFailure('down')));
    });
  });

  test('SoldierProfileExists reads Men/{uid}', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('Men').doc('s1').set({'name': 'Lim Bah'});
    final useCase =
        SoldierProfileExists(MenRepositoryImpl(MenRemoteDataSource(db)));
    expect(await useCase('s1'), const Right<Failure, bool>(true));
    expect(await useCase('s2'), const Right<Failure, bool>(false));
  });
}
