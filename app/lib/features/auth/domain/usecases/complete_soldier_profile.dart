import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../enlistment/domain/repositories/men_repository.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';

/// Profile capture (R16): `Men/{uid}` → display name → `is_signedin`.
class CompleteSoldierProfile implements UseCase<Unit, Soldier> {
  const CompleteSoldierProfile(this._auth, this._men);

  static const detailsMissing = 'Details missing';

  final AuthRepository _auth;
  final MenRepository _men;

  @override
  Result<Unit> call(Soldier profile) async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Left(AuthFailure('Session expired. Sign in again.'));
    }
    final name = profile.name.trim();
    final error = AuthValidators.soldierName(name) ??
        (_isComplete(profile) ? null : detailsMissing);
    if (error != null) return Left(ValidationFailure(error));

    final steps = [
      () => _men.save(user.uid, profile.copyWith(id: name, name: name)),
      () => _auth.updateDisplayName(name),
      () => _auth.markSoldierSignedIn(),
    ];
    for (final step in steps) {
      final result = await step();
      if (result.isLeft()) return result;
    }
    return const Right(unit);
  }

  /// K17 fix: every field, including the three dates, must be filled.
  static bool _isComplete(Soldier p) =>
      [
        p.rank,
        p.company,
        p.platoon,
        p.section,
        p.appointment,
        p.rationType,
        p.bloodGroup,
      ].every((v) => v.trim().isNotEmpty) &&
      p.dob != null &&
      p.enlistment != null &&
      p.ord != null;
}
