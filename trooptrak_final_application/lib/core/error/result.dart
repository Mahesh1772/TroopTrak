import 'package:dartz/dartz.dart';

import 'failures.dart';

typedef Result<T> = Future<Either<Failure, T>>;

typedef ResultStream<T> = Stream<Either<Failure, T>>;
