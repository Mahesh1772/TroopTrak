import 'package:dartz/dartz.dart';

import '../../../../core/error/result.dart';
import '../entities/attendance_record.dart';

abstract interface class AttendanceRepository {
  ResultStream<List<AttendanceRecord>> watchForSoldier(String soldierId);

  /// Every soldier's records, for the effective in-camp state (R21).
  ResultStream<List<AttendanceRecord>> watchAll();

  /// R10: writes the record and `currentAttendance` together.
  Result<Unit> bookInOut(String soldierId, bool isInsideCamp, DateTime at);

  /// Changes the record's date and time; the doc id is kept, as in the source.
  Result<Unit> update(AttendanceRecord record);

  Result<Unit> delete(AttendanceRecord record);
}
