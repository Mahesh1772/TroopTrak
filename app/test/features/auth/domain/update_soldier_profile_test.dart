import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/update_soldier_profile.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/repositories/men_repository.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/repositories/soldier_repository.dart';

import '../../../helpers/builders.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockMen extends Mock implements MenRepository {}

class _MockSoldiers extends Mock implements SoldierRepository {}

void main() {
  late _MockAuth auth;
  late _MockMen men;
  late _MockSoldiers soldiers;
  late UpdateSoldierProfile useCase;

  setUpAll(() => registerFallbackValue(buildSoldier()));

  setUp(() {
    auth = _MockAuth();
    men = _MockMen();
    soldiers = _MockSoldiers();
    useCase = UpdateSoldierProfile(auth, men, soldiers);
    when(() => auth.currentUser).thenReturn(const AuthUser(uid: 'u1'));
    when(() => men.updateProfile(any(), any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => soldiers.exists(any()))
        .thenAnswer((_) async => const Right(true));
    when(() => soldiers.update(any()))
        .thenAnswer((_) async => const Right(unit));
  });

  test('updates Men/{uid}, then the linked Users doc under its old id',
      () async {
    final edited = buildSoldier(id: 'Lim Bah', name: '  Lim Ah Kow  ');
    final saved = edited.copyWith(name: 'Lim Ah Kow');
    expect(await useCase(edited), const Right<Failure, Unit>(unit));
    verifyInOrder([
      () => men.updateProfile('u1', saved),
      () => soldiers.exists('Lim Bah'),
      () => soldiers.update(saved),
    ]);
  });

  test('a soldier not yet on the nominal roll updates Men only', () async {
    when(() => soldiers.exists(any()))
        .thenAnswer((_) async => const Right(false));
    expect(await useCase(buildSoldier()), const Right<Failure, Unit>(unit));
    verify(() => men.updateProfile('u1', any())).called(1);
    verifyNever(() => soldiers.update(any()));
  });

  test('a failed Men write stops before Users', () async {
    when(() => men.updateProfile(any(), any()))
        .thenAnswer((_) async => const Left(ServerFailure('down')));
    expect(await useCase(buildSoldier()),
        const Left<Failure, Unit>(ServerFailure('down')));
    verifyNever(() => soldiers.exists(any()));
  });

  test('a failed Users lookup is returned', () async {
    when(() => soldiers.exists(any()))
        .thenAnswer((_) async => const Left(ServerFailure('down')));
    expect(await useCase(buildSoldier()),
        const Left<Failure, Unit>(ServerFailure('down')));
    verifyNever(() => soldiers.update(any()));
  });

  test('no signed-in user is an AuthFailure and writes nothing', () async {
    when(() => auth.currentUser).thenReturn(null);
    expect((await useCase(buildSoldier())).isLeft(), isTrue);
    verifyNever(() => men.updateProfile(any(), any()));
  });

  test('an invalid name is refused before any write (R20)', () async {
    expect(
        await useCase(buildSoldier(name: 'Lim')),
        const Left<Failure, Unit>(
            ValidationFailure('Brother, enter full name leh')));
    verifyNever(() => men.updateProfile(any(), any()));
  });
}
