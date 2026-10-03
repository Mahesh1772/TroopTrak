import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../entities/soldier.dart';

abstract interface class SoldierRepository {
  ResultStream<List<Soldier>> watchAll();

  ResultStream<Soldier> watchById(String id);

  Result<List<Soldier>> getAll();

  Result<bool> exists(String id);

  /// Writes `Users/{soldier.id}` and its first attendance record (R17).
  Result<Unit> add(Soldier soldier, {required DateTime createdAt});

  /// Updates profile fields only; attendance and points are left untouched.
  Result<Unit> update(Soldier soldier);

  /// Deletes statuses, attendance and the soldier document (R14).
  Result<Unit> delete(String id);
}
