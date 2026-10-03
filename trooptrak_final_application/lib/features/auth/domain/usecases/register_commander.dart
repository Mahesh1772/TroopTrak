import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:recase/recase.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../../../soldiers/domain/repositories/soldier_repository.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';
import '../validators/password_rules.dart';

class CommanderRegistration extends Equatable {
  const CommanderRegistration({
    required this.email,
    required this.password,
    required this.profile,
  });

  final String email;
  final String password;

  /// Profile fields; id and name are derived from [Soldier.name].
  final Soldier profile;

  @override
  List<Object?> get props => [email, password, profile];
}

/// Source register flow: account → TitleCase display name → `Users/{name}`
/// with first attendance (R17) → sign out of Firebase, keeping preferences.
class RegisterCommander implements UseCase<Unit, CommanderRegistration> {
  const RegisterCommander(this._auth, this._soldiers, this._clock);

  final AuthRepository _auth;
  final SoldierRepository _soldiers;
  final Clock _clock;

  @override
  Result<Unit> call(CommanderRegistration r) async {
    final error = AuthValidators.email(r.email) ??
        AuthValidators.password(r.password) ??
        (PasswordRule.isStrong(r.password.trim())
            ? null
            : 'Password needs to be stronger');
    if (error != null) return Left(ValidationFailure(error));

    final name = r.profile.name.trim().titleCase;
    if (name.isEmpty) {
      return const Left(ValidationFailure('You must have a name right'));
    }

    final exists = await _soldiers.exists(name);
    final duplicate = exists.fold(
        (f) => f,
        (found) => found
            ? ValidationFailure('A soldier named $name already exists.')
            : null);
    if (duplicate != null) return Left(duplicate);

    final account =
        await _auth.registerWithEmail(r.email.trim(), r.password.trim());
    if (account.isLeft()) return account.map((_) => unit);

    final steps = [
      () => _auth.updateDisplayName(name),
      () => _soldiers.add(
            r.profile.copyWith(id: name, name: name, isInCamp: true, points: 0),
            createdAt: _clock.now(),
          ),
      () => _auth.signOut(clearPreferences: false),
    ];
    for (final step in steps) {
      final result = await step();
      if (result.isLeft()) return result;
    }
    return const Right(unit);
  }
}
