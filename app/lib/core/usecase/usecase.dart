import 'package:equatable/equatable.dart';

import '../error/result.dart';

abstract interface class UseCase<T, P> {
  Result<T> call(P params);
}

abstract interface class StreamUseCase<T, P> {
  ResultStream<T> call(P params);
}

final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const [];
}
