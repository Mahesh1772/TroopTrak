import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../entities/soldier_registration.dart';

/// Soldier self-registration records in `Men/{uid}` (R16).
abstract interface class MenRepository {
  Result<bool> exists(String uid);

  /// `NotFoundFailure` when the soldier has not registered.
  Result<SoldierRegistration> get(String uid);

  /// The soldier's own record, kept live (their My Profile tab).
  ResultStream<SoldierRegistration> watch(String uid);

  /// Changes the profile fields only; points and QR code stay.
  Result<Unit> updateProfile(String uid, Soldier profile);

  /// Writes the whole registration with `points: 0` and no QR code (R16).
  Result<Unit> save(String uid, Soldier profile);

  /// Merges `QRid` only; null clears it (R15).
  Result<Unit> setQrId(String uid, String? qrId);

  /// `Right(null)` when no soldier currently shows [qrId].
  Result<SoldierRegistration?> findByQrId(String qrId);
}
