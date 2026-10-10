import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/features/auth/domain/entities/auth_user.dart';
import 'package:trooptrak_final_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:trooptrak_final_application/features/auth/domain/usecases/complete_soldier_profile.dart';
import 'package:trooptrak_final_application/features/enlistment/domain/repositories/men_repository.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';

import '../../../helpers/builders.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockMen extends Mock implements MenRepository {}

void main() {
  late _MockAuth auth;
  late _MockMen men;
  late CompleteSoldierProfile useCase;

  setUpAll(() => registerFallbackValue(buildSoldier()));

  setUp(() {
    auth = _MockAuth();
    men = _MockMen();
    useCase = CompleteSoldierProfile(auth, men);
    when(() => auth.currentUser).thenReturn(const AuthUser(uid: 'u1'));
    when(() => men.save(any(), any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => auth.updateDisplayName(any()))
        .thenAnswer((_) async => const Right(unit));
    when(() => auth.markSoldierSignedIn())
        .thenAnswer((_) async => const Right(unit));
  });

  test('saves Men/{uid}, sets the display name, then marks signed in (R16)',
      () async {
    final profile = buildSoldier(name: '  Lim Bah  ', id: '', rank: 'PTE');
    expect(await useCase(profile), const Right<Failure, Unit>(unit));
    verifyInOrder([
      () => men.save('u1', profile.copyWith(id: 'Lim Bah', name: 'Lim Bah')),
      () => auth.updateDisplayName('Lim Bah'),
      () => auth.markSoldierSignedIn(),
    ]);
  });

  test('no signed-in user is an AuthFailure and writes nothing', () async {
    when(() => auth.currentUser).thenReturn(null);
    expect((await useCase(buildSoldier())).isLeft(), isTrue);
    verifyNever(() => men.save(any(), any()));
  });

  for (final (name, message) in [
    ('', 'Must have a name right'),
    ('12345', 'Name got number meh'),
    ('Lim', 'Brother, enter full name leh'),
  ]) {
    test('name "$name" is rejected with "$message" (R20)', () async {
      expect(await useCase(buildSoldier(name: name)),
          Left<Failure, Unit>(ValidationFailure(message)));
      verifyNever(() => men.save(any(), any()));
    });
  }

  final incomplete = <String, Soldier>{
    'rank': buildSoldier(rank: ''),
    'company': buildSoldier(company: ' '),
    'blood group': buildSoldier(bloodGroup: ''),
    'dob': _withoutDate(dob: true),
    'enlistment': _withoutDate(enlistment: true),
    'ord': _withoutDate(ord: true),
  };
  for (final entry in incomplete.entries) {
    test('missing ${entry.key} is "Details missing" (K17)', () async {
      expect(await useCase(entry.value),
          const Left<Failure, Unit>(ValidationFailure('Details missing')));
    });
  }

  test('a failed save stops before the display name', () async {
    when(() => men.save(any(), any()))
        .thenAnswer((_) async => const Left(ServerFailure('down')));
    expect(await useCase(buildSoldier()),
        const Left<Failure, Unit>(ServerFailure('down')));
    verifyNever(() => auth.updateDisplayName(any()));
    verifyNever(() => auth.markSoldierSignedIn());
  });
}

Soldier _withoutDate(
    {bool dob = false, bool enlistment = false, bool ord = false}) {
  final s = buildSoldier();
  return Soldier(
    id: s.id,
    name: s.name,
    rank: s.rank,
    company: s.company,
    platoon: s.platoon,
    section: s.section,
    appointment: s.appointment,
    rationType: s.rationType,
    bloodGroup: s.bloodGroup,
    dob: dob ? null : s.dob,
    enlistment: enlistment ? null : s.enlistment,
    ord: ord ? null : s.ord,
  );
}
