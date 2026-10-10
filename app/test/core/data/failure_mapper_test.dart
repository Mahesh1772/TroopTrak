import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/data/failure_mapper.dart';
import 'package:trooptrak_final_application/core/error/exceptions.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';

void main() {
  group('mapError', () {
    test('FirebaseAuthException keeps Firebase message and code', () {
      final failure = mapError(
        FirebaseAuthException(code: 'wrong-password', message: 'Bad password'),
      );
      expect(
          failure, const AuthFailure('Bad password', code: 'wrong-password'));
    });

    test('FirebaseAuthException without message falls back by code', () {
      expect(
        mapError(FirebaseAuthException(code: 'invalid-email')),
        const AuthFailure('The email address is badly formatted.',
            code: 'invalid-email'),
      );
      expect(
        mapError(FirebaseAuthException(code: 'email-already-in-use')).message,
        'The email address is already in use by another account.',
      );
      expect(
        mapError(FirebaseAuthException(code: 'invalid-verification-code'))
            .message,
        'The OTP entered is invalid.',
      );
      expect(
        mapError(FirebaseAuthException(code: 'something-new')).message,
        'Authentication failed. Please try again.',
      );
    });

    test('FirebaseException codes map to failure types', () {
      expect(
        mapError(
            FirebaseException(plugin: 'cloud_firestore', code: 'not-found')),
        isA<NotFoundFailure>(),
      );
      expect(
        mapError(FirebaseException(
            plugin: 'cloud_firestore', code: 'permission-denied')),
        const ServerFailure(
            'You do not have permission to perform this action.'),
      );
      expect(
        mapError(
            FirebaseException(plugin: 'cloud_firestore', code: 'unavailable')),
        isA<ServerFailure>(),
      );
      expect(
        mapError(FirebaseException(
            plugin: 'cloud_firestore', code: 'aborted', message: 'boom')),
        const ServerFailure('boom'),
      );
    });

    test('app exceptions map to matching failures', () {
      expect(mapError(const NotFoundException('gone')),
          const NotFoundFailure('gone'));
      expect(mapError(const CacheException()), const CacheFailure());
      expect(mapError(const ValidationException('bad')),
          const ValidationFailure('bad'));
      expect(
          mapError(const ServerException('down')), const ServerFailure('down'));
    });

    test('failures pass through and unknown errors become ServerFailure', () {
      expect(
          mapError(const ValidationFailure('v')), const ValidationFailure('v'));
      expect(mapError(StateError('x')), const ServerFailure());
    });
  });

  group('guard', () {
    test('returns Right on success', () async {
      expect(await guard(() async => 42), const Right<Failure, int>(42));
    });

    test('returns Left with the mapped failure on error', () async {
      final result =
          await guard<int>(() async => throw const NotFoundException('none'));
      expect(result, const Left<Failure, int>(NotFoundFailure('none')));
    });
  });

  group('guardStream', () {
    test('wraps values in Right and errors in Left without closing', () async {
      final source = Stream<int>.fromIterable([1]).asyncExpand(
        (v) => Stream<int>.multi((c) {
          c.add(v);
          c.addError(const ServerException('down'));
          c.add(2);
          c.close();
        }),
      );

      expect(
        await guardStream(source).toList(),
        const [
          Right<Failure, int>(1),
          Left<Failure, int>(ServerFailure('down')),
          Right<Failure, int>(2),
        ],
      );
    });
  });
}
