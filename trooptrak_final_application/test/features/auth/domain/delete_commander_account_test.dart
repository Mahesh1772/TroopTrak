import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/delete_commander_account.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/repositories/soldier_repository.dart';

import '../../../helpers/fake_clock.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockSoldiers extends Mock implements SoldierRepository {}

void main() {
  late _MockAuth auth;
  late _MockSoldiers soldiers;
  final now = DateTime(2023, 7, 5, 9);
  late DeleteCommanderAccount useCase;

  setUp(() {
    auth = _MockAuth();
    soldiers = _MockSoldiers();
    useCase = DeleteCommanderAccount(auth, soldiers, FixedClock(now));
    when(() => auth.currentUser).thenReturn(AuthUser(
        uid: 'c1',
        displayName: 'Cmd Lim',
        lastSignInAt: now.subtract(const Duration(minutes: 2))));
    when(() => soldiers.delete(any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => auth.deleteAccount()).thenAnswer((_) async => const Right(unit));
  });

  test('recent sign-in: cascade-deletes the Users doc, then the account (K19)',
      () async {
    expect(await useCase('Cmd Lim'), const Right<Failure, Unit>(unit));
    verifyInOrder([
      () => soldiers.delete('Cmd Lim'),
      () => auth.deleteAccount(),
    ]);
  });

  test('a stale sign-in is refused before anything is deleted', () async {
    when(() => auth.currentUser).thenReturn(AuthUser(
        uid: 'c1', lastSignInAt: now.subtract(const Duration(minutes: 6))));
    expect(await useCase('Cmd Lim'),
        const Left<Failure, Unit>(AuthFailure(reSignInMessage)));
    verifyNever(() => soldiers.delete(any()));
    verifyNever(() => auth.deleteAccount());
  });

  test('no signed-in user is an AuthFailure', () async {
    when(() => auth.currentUser).thenReturn(null);
    expect((await useCase('Cmd Lim')).isLeft(), isTrue);
    verifyNever(() => soldiers.delete(any()));
  });

  test('a failed data delete keeps the account', () async {
    when(() => soldiers.delete(any()))
        .thenAnswer((_) async => const Left(ServerFailure('down')));
    expect(await useCase('Cmd Lim'),
        const Left<Failure, Unit>(ServerFailure('down')));
    verifyNever(() => auth.deleteAccount());
  });
}
