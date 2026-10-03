import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../entities/auth_user.dart';
import '../entities/phone_auth_event.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Result<AuthUser> signInWithEmail(String email, String password);

  Result<AuthUser> registerWithEmail(String email, String password);

  Result<Unit> sendPasswordReset(String email);

  Stream<PhoneAuthEvent> verifyPhone(String phoneNumber, {int? resendToken});

  Result<AuthUser> verifyOtp(String verificationId, String smsCode);

  Result<Unit> updateDisplayName(String name);

  /// The soldier app's `is_signedin` preference.
  bool get isSoldierSignedIn;

  Result<Unit> markSoldierSignedIn();

  /// Deletes the signed-in Firebase account (which also signs it out).
  Result<Unit> deleteAccount();

  /// Signs out and clears every preference, including the role (R19, D4).
  /// Registration signs out with [clearPreferences] false, as the source did.
  Result<Unit> signOut({bool clearPreferences = true});
}
