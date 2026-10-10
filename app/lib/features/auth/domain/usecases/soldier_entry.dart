import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../enlistment/domain/repositories/men_repository.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

enum SoldierEntry { home, profileCapture, phoneEntry }

/// R19 soldier gate: signed in + `Men/{uid}` → home; signed in without a
/// profile → capture; otherwise phone entry.
class ResolveSoldierEntry implements UseCase<SoldierEntry, NoParams> {
  const ResolveSoldierEntry(this._auth, this._men);

  final AuthRepository _auth;
  final MenRepository _men;

  @override
  Result<SoldierEntry> call(NoParams params) async {
    final user = _auth.currentUser;
    if (user == null) return const Right(SoldierEntry.phoneEntry);
    final exists = await _men.exists(user.uid);
    return exists.map((found) {
      if (!found) return SoldierEntry.profileCapture;
      return _auth.isSoldierSignedIn
          ? SoldierEntry.home
          : SoldierEntry.phoneEntry;
    });
  }
}

/// After phone verification: existing profile → mark signed in, go home;
/// new soldier → profile capture.
class CompleteSoldierSignIn implements UseCase<SoldierEntry, AuthUser> {
  const CompleteSoldierSignIn(this._auth, this._men);

  final AuthRepository _auth;
  final MenRepository _men;

  @override
  Result<SoldierEntry> call(AuthUser user) async {
    final exists = await _men.exists(user.uid);
    final found = exists.fold((_) => null, (value) => value);
    if (found == null) return exists.map((_) => SoldierEntry.phoneEntry);
    if (!found) return const Right(SoldierEntry.profileCapture);
    final marked = await _auth.markSoldierSignedIn();
    return marked.map((_) => SoldierEntry.home);
  }
}
