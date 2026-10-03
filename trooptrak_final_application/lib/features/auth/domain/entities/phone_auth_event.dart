import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import 'auth_user.dart';

sealed class PhoneAuthEvent extends Equatable {
  const PhoneAuthEvent();

  @override
  List<Object?> get props => [];
}

final class OtpSent extends PhoneAuthEvent {
  const OtpSent(this.verificationId, {this.resendToken});

  final String verificationId;
  final int? resendToken;

  @override
  List<Object?> get props => [verificationId, resendToken];
}

final class PhoneAutoVerified extends PhoneAuthEvent {
  const PhoneAutoVerified(this.user);

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

final class PhoneVerificationError extends PhoneAuthEvent {
  const PhoneVerificationError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class OtpTimeout extends PhoneAuthEvent {
  const OtpTimeout(this.verificationId);

  final String verificationId;

  @override
  List<Object?> get props => [verificationId];
}
