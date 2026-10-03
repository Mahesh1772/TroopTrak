import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../entities/status.dart';

abstract interface class StatusRepository {
  ResultStream<List<Status>> watchForSoldier(String soldierId);

  /// Statuses of every soldier, kept live.
  ResultStream<List<Status>> watchAll();

  /// Statuses of every soldier, fetched in parallel.
  Result<List<Status>> getAll();

  /// Writes the status and its linked attendance records (R21).
  Result<Unit> add(Status status);

  /// Replaces [previous] with [updated], moving linked attendance records (R21, K15).
  Result<Unit> update(Status previous, Status updated);

  /// Deletes the status and its linked attendance records (R21).
  Result<Unit> delete(Status status);
}
