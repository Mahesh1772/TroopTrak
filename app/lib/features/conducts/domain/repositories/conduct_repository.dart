import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../entities/conduct.dart';

abstract interface class ConductRepository {
  ResultStream<List<Conduct>> watchAll();

  /// Conducts whose `startDate` is [day] (R13).
  ResultStream<List<Conduct>> watchOnDay(DateTime day);

  ResultStream<Conduct> watchById(String id);

  Result<Unit> add(Conduct conduct);

  Result<Unit> update(Conduct conduct);

  Result<Unit> delete(String id);
}
