import 'package:dartz/dartz.dart';

import '../../../../core/data/failure_mapper.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/preferences_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/phone_auth_event.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._preferences);

  final FirebaseAuthDataSource _remote;
  final PreferencesService _preferences;

  @override
  Stream<AuthUser?> authStateChanges() => _remote.authStateChanges();

  @override
  AuthUser? get currentUser => _remote.currentUser;

  @override
  Result<AuthUser> signInWithEmail(String email, String password) =>
      guard(() => _remote.signInWithEmail(email, password));

  @override
  Result<AuthUser> registerWithEmail(String email, String password) =>
      guard(() => _remote.registerWithEmail(email, password));

  @override
  Result<Unit> sendPasswordReset(String email) => guard(() async {
        await _remote.sendPasswordReset(email);
        return unit;
      });

  @override
  Stream<PhoneAuthEvent> verifyPhone(String phoneNumber, {int? resendToken}) =>
      _remote.verifyPhone(phoneNumber, resendToken: resendToken);

  @override
  Result<AuthUser> verifyOtp(String verificationId, String smsCode) =>
      guard(() => _remote.verifyOtp(verificationId, smsCode));

  @override
  Result<Unit> updateDisplayName(String name) => guard(() async {
        await _remote.updateDisplayName(name);
        return unit;
      });

  @override
  Result<Unit> deleteAccount() => guard(() async {
        await _remote.deleteAccount();
        return unit;
      });

  @override
  bool get isSoldierSignedIn => _preferences.isSignedIn;

  @override
  Result<Unit> markSoldierSignedIn() => guard(() async {
        await _preferences.setSignedIn(true);
        return unit;
      });

  @override
  Result<Unit> signOut({bool clearPreferences = true}) => guard(() async {
        await _remote.signOut();
        if (clearPreferences) await _preferences.clearAll();
        return unit;
      });
}
