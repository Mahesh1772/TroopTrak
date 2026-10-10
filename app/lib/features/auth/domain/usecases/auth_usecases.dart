import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../entities/phone_auth_event.dart';
import '../repositories/auth_repository.dart';
import '../validators/auth_validators.dart';

class EmailCredentials extends Equatable {
  const EmailCredentials(this.email, this.password);

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

ValidationFailure? _invalid(EmailCredentials c) {
  final error =
      AuthValidators.email(c.email) ?? AuthValidators.password(c.password);
  return error == null ? null : ValidationFailure(error);
}

class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  Stream<AuthUser?> call() => _repository.authStateChanges();

  AuthUser? get current => _repository.currentUser;
}

class SignInWithEmail implements UseCase<AuthUser, EmailCredentials> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Result<AuthUser> call(EmailCredentials c) async {
    final invalid = _invalid(c);
    if (invalid != null) return Left(invalid);
    return _repository.signInWithEmail(c.email.trim(), c.password.trim());
  }
}

class SendPasswordReset implements UseCase<Unit, String> {
  const SendPasswordReset(this._repository);

  final AuthRepository _repository;

  @override
  Result<Unit> call(String email) async {
    final error = AuthValidators.email(email);
    if (error != null) return Left(ValidationFailure(error));
    return _repository.sendPasswordReset(email.trim());
  }
}

class PhoneParams extends Equatable {
  const PhoneParams(this.phoneNumber, {this.resendToken});

  /// Full E.164 number, e.g. +6591234567.
  final String phoneNumber;
  final int? resendToken;

  @override
  List<Object?> get props => [phoneNumber, resendToken];
}

class VerifyPhone {
  const VerifyPhone(this._repository);

  final AuthRepository _repository;

  Stream<PhoneAuthEvent> call(PhoneParams params) => _repository
      .verifyPhone(params.phoneNumber, resendToken: params.resendToken);
}

class OtpParams extends Equatable {
  const OtpParams(this.verificationId, this.smsCode);

  final String verificationId;
  final String smsCode;

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class VerifyOtp implements UseCase<AuthUser, OtpParams> {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  @override
  Result<AuthUser> call(OtpParams params) async {
    final error = AuthValidators.otp(params.smsCode);
    if (error != null) return Left(ValidationFailure(error));
    return _repository.verifyOtp(params.verificationId, params.smsCode);
  }
}

class SignOut implements UseCase<Unit, NoParams> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Result<Unit> call(NoParams params) => _repository.signOut();
}
