import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/data/failure_mapper.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/phone_auth_event.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  static AuthUser? toAuthUser(User? user) => user == null
      ? null
      : AuthUser(
          uid: user.uid,
          displayName: user.displayName,
          phoneNumber: user.phoneNumber,
          email: user.email,
          lastSignInAt: user.metadata.lastSignInTime,
        );

  Stream<AuthUser?> authStateChanges() =>
      _auth.authStateChanges().map(toAuthUser);

  AuthUser? get currentUser => toAuthUser(_auth.currentUser);

  Future<AuthUser> signInWithEmail(String email, String password) async =>
      _required((await _auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user);

  Future<AuthUser> registerWithEmail(String email, String password) async =>
      _required((await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user);

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Stream<PhoneAuthEvent> verifyPhone(String phoneNumber, {int? resendToken}) {
    late final StreamController<PhoneAuthEvent> controller;

    void emit(PhoneAuthEvent event, {bool last = false}) {
      if (controller.isClosed) return;
      controller.add(event);
      if (last) unawaited(controller.close());
    }

    controller = StreamController<PhoneAuthEvent>(
      onListen: () async {
        try {
          await _auth.verifyPhoneNumber(
            phoneNumber: phoneNumber,
            timeout: const Duration(seconds: 60),
            forceResendingToken: resendToken,
            verificationCompleted: (credential) async {
              try {
                final result = await _auth.signInWithCredential(credential);
                emit(PhoneAutoVerified(_required(result.user)), last: true);
              } catch (e) {
                emit(PhoneVerificationError(mapError(e)), last: true);
              }
            },
            verificationFailed: (e) =>
                emit(PhoneVerificationError(mapError(e)), last: true),
            codeSent: (id, token) => emit(OtpSent(id, resendToken: token)),
            codeAutoRetrievalTimeout: (id) => emit(OtpTimeout(id), last: true),
          );
        } catch (e) {
          emit(PhoneVerificationError(mapError(e)), last: true);
        }
      },
    );
    return controller.stream;
  }

  Future<AuthUser> verifyOtp(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _required((await _auth.signInWithCredential(credential)).user);
  }

  Future<void> updateDisplayName(String name) =>
      _signedIn.updateDisplayName(name);

  Future<void> deleteAccount() => _signedIn.delete();

  User get _signedIn =>
      _auth.currentUser ??
      (throw FirebaseAuthException(
          code: 'no-current-user', message: 'No signed-in user.'));

  Future<void> signOut() => _auth.signOut();

  AuthUser _required(User? user) =>
      toAuthUser(user) ??
      (throw FirebaseAuthException(
          code: 'user-not-found', message: 'Sign-in returned no user.'));
}
