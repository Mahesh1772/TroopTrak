import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';

void main() {
  test('failures with the same type and message are equal', () {
    expect(const ServerFailure('x'), const ServerFailure('x'));
    expect(const NotFoundFailure(), const NotFoundFailure());
    expect(const ValidationFailure('bad'), const ValidationFailure('bad'));
    expect(const CacheFailure(), const CacheFailure());
    expect(
        const AuthFailure('m', code: 'c'), const AuthFailure('m', code: 'c'));
  });

  test('failures differ by message, code or type', () {
    expect(const ServerFailure('a'), isNot(const ServerFailure('b')));
    expect(const AuthFailure('m', code: 'a'),
        isNot(const AuthFailure('m', code: 'b')));
    expect(const ServerFailure('m'), isNot(const ValidationFailure('m')));
  });

  test('default messages are set', () {
    expect(const ServerFailure().message, isNotEmpty);
    expect(const NotFoundFailure().message, isNotEmpty);
    expect(const CacheFailure().message, isNotEmpty);
  });
}
