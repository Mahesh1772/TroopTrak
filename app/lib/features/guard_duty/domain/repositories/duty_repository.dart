import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../entities/duty.dart';
import '../services/duty_points.dart';

/// Every write also moves `Users/{name}.points` in the same transaction
/// (K5): [changes] maps soldier names to their [PointsChange].
abstract interface class DutyRepository {
  ResultStream<List<Duty>> watchAll();

  Result<Unit> add(Duty duty, Map<String, PointsChange> changes);

  Result<Unit> update(Duty duty, Map<String, PointsChange> changes);

  Result<Unit> delete(Duty duty, Map<String, PointsChange> changes);
}
