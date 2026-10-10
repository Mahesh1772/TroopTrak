import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/clock.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../soldiers/domain/repositories/soldier_repository.dart';
import '../repositories/auth_repository.dart';

/// K19 fix: own-account delete removes `Users/{id}` with its statuses and
/// attendance (R14), then the Firebase account, as the source did. It refuses
/// up front when the sign-in is too old for Firebase to allow the account
/// delete, so data is never removed while the account would remain.
class DeleteCommanderAccount implements UseCase<Unit, String> {
  const DeleteCommanderAccount(this._auth, this._soldiers, this._clock);

  static const recentLogin = Duration(minutes: 5);

  final AuthRepository _auth;
  final SoldierRepository _soldiers;
  final Clock _clock;

  @override
  Result<Unit> call(String soldierId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return const Left(AuthFailure('Session expired. Sign in again.'));
    }
    final signedInAt = user.lastSignInAt;
    if (signedInAt == null ||
        _clock.now().difference(signedInAt) > recentLogin) {
      return const Left(AuthFailure(reSignInMessage));
    }
    final data = await _soldiers.delete(soldierId);
    if (data.isLeft()) return data;
    return _auth.deleteAccount();
  }
}
