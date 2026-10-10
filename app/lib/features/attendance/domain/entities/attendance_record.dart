import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.soldierId,
    required this.isInsideCamp,
    required this.timestamp,
  });

  /// Doc id `yyyy-MM-dd HH:mm:ss` of the original booking; edits keep it.
  final String id;
  final String soldierId;
  final bool isInsideCamp;
  final DateTime timestamp;

  AttendanceRecord copyWith({bool? isInsideCamp, DateTime? timestamp}) =>
      AttendanceRecord(
        id: id,
        soldierId: soldierId,
        isInsideCamp: isInsideCamp ?? this.isInsideCamp,
        timestamp: timestamp ?? this.timestamp,
      );

  @override
  List<Object?> get props => [id, soldierId, isInsideCamp, timestamp];
}

DateTime _minute(DateTime t) =>
    DateTime(t.year, t.month, t.day, t.hour, t.minute);

/// R11: newest first; records later than the current minute are hidden.
List<AttendanceRecord> visibleAttendance(
  Iterable<AttendanceRecord> records,
  DateTime now,
) {
  final cutoff = _minute(now);
  return [
    for (final r in records)
      if (!_minute(r.timestamp).isAfter(cutoff)) r,
  ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
}

/// R21: latest visible record decides; [fallback] (stored currentAttendance) otherwise.
bool effectiveInCamp(
  Iterable<AttendanceRecord> records,
  DateTime now, {
  required bool fallback,
}) {
  final visible = visibleAttendance(records, now);
  return visible.isEmpty ? fallback : visible.first.isInsideCamp;
}
