import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/error/failures.dart';
import 'package:trooptrak_final_application/core/error/result.dart';
import 'package:trooptrak_final_application/core/usecase/usecase.dart';

class _Double implements UseCase<int, int> {
  @override
  Result<int> call(int params) async => params < 0
      ? const Left(ValidationFailure('negative'))
      : Right(params * 2);
}

class _Count implements StreamUseCase<int, NoParams> {
  @override
  ResultStream<int> call(NoParams params) =>
      Stream.fromIterable([1, 2]).map((v) => Right(v));
}

void main() {
  test('UseCase returns Right or Left from call', () async {
    final useCase = _Double();
    expect(await useCase(3), const Right<Failure, int>(6));
    expect(await useCase(-1),
        const Left<Failure, int>(ValidationFailure('negative')));
  });

  test('StreamUseCase emits Either values', () async {
    expect(await _Count()(const NoParams()).toList(),
        const [Right<Failure, int>(1), Right<Failure, int>(2)]);
  });

  test('NoParams instances are equal', () {
    expect(const NoParams(), const NoParams());
  });
}
