import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../enlistment/domain/repositories/men_repository.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/repositories/soldier_repository.dart';
import '../../../soldiers/domain/validators/soldier_validators.dart';
import '../repositories/auth_repository.dart';

/// Soldier edits their own details: `Men/{uid}`, then the linked commander
/// record `Users/{profile.id}` when it exists (user decision; the source
/// updated Men only). The Users doc id never changes (K8, K14).
class UpdateSoldierProfile implements UseCase<Unit, Soldier> {
  const UpdateSoldierProfile(this._auth, this._men, this._soldiers);

  final AuthRepository _auth;
  final MenRepository _men;
  final SoldierRepository _soldiers;

  @override
  Result<Unit> call(Soldier profile) async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Left(AuthFailure('Session expired. Sign in again.'));
    }
    final name = profile.name.trim();
    final invalid = SoldierValidators.name(name);
    if (invalid != null) return Left(ValidationFailure(invalid));

    final updated = profile.copyWith(name: name);
    final men = await _men.updateProfile(user.uid, updated);
    if (men.isLeft()) return men;

    final linked = await _soldiers.exists(profile.id);
    final hasUsersDoc = linked.fold((_) => null, (found) => found);
    if (hasUsersDoc == null) return linked.map((_) => unit);
    if (!hasUsersDoc) return const Right(unit);
    return _soldiers.update(updated);
  }
}
