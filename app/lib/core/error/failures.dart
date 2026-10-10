import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure(
      [super.message = 'Something went wrong. Please try again.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(
      [super.message = 'The requested record was not found.']);
}

/// Firebase refuses sensitive account changes without a recent sign-in.
const reSignInMessage =
    'For security, sign out and sign in again, then delete your account.';

final class AuthFailure extends Failure {
  const AuthFailure(super.message, {this.code});

  final String? code;

  @override
  List<Object?> get props => [message, code];
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not access local storage.']);
}
