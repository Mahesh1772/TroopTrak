import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';
import '../error/result.dart';

Failure mapError(Object error) => switch (error) {
      final Failure f => f,
      final FirebaseAuthException e =>
        AuthFailure(e.message ?? authMessageFor(e.code), code: e.code),
      final FirebaseException e => _firebaseFailure(e),
      NotFoundException(:final message) =>
        message == null ? const NotFoundFailure() : NotFoundFailure(message),
      CacheException(:final message) =>
        message == null ? const CacheFailure() : CacheFailure(message),
      ValidationException(:final message) => ValidationFailure(message),
      ServerException(:final message) =>
        message == null ? const ServerFailure() : ServerFailure(message),
      _ => const ServerFailure(),
    };

String authMessageFor(String code) => switch (code) {
      'invalid-email' => 'The email address is badly formatted.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'The email or password is incorrect.',
      'email-already-in-use' =>
        'The email address is already in use by another account.',
      'weak-password' => 'The password is too weak.',
      'invalid-verification-code' => 'The OTP entered is invalid.',
      'invalid-phone-number' => 'The phone number is invalid.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' => 'Network error. Check your connection.',
      _ => 'Authentication failed. Please try again.',
    };

Failure _firebaseFailure(FirebaseException e) => switch (e.code) {
      'not-found' =>
        NotFoundFailure(e.message ?? 'The requested record was not found.'),
      'permission-denied' => const ServerFailure(
          'You do not have permission to perform this action.'),
      'unavailable' => const ServerFailure(
          'The service is unavailable. Check your connection and try again.'),
      _ =>
        e.message == null ? const ServerFailure() : ServerFailure(e.message!),
    };

Result<T> guard<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } catch (error) {
    return Left(mapError(error));
  }
}

ResultStream<T> guardStream<T>(Stream<T> stream) => stream
    .map<Either<Failure, T>>((value) => Right(value))
    .transform(StreamTransformer.fromHandlers(
      handleError: (error, _, sink) => sink.add(Left(mapError(error))),
    ));
