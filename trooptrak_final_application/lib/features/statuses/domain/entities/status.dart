import 'package:equatable/equatable.dart';

import '../../../../core/constants/status_types.dart';
import '../../../../core/utils/date_formats.dart';

typedef LinkedAttendance = ({DateTime at, bool isInsideCamp});

class Status extends Equatable {
  const Status({
    required this.id,
    required this.soldierId,
    required this.type,
    required this.name,
    required this.start,
    required this.end,
    this.startAttendanceId,
    this.endAttendanceId,
  });

  final String id;
  final String soldierId;
  final String type;
  final String name;
  final DateTime start;
  final DateTime end;

  /// Stored `start_id` / `end_id`: ids of the linked attendance records (R21).
  final String? startAttendanceId;
  final String? endAttendanceId;

  bool get isExcuse => type == StatusTypes.excuse;
  bool get isLeave => type == StatusTypes.leave;
  bool get isMedicalAppointment => type == StatusTypes.medicalAppointment;

  /// R2: active up to and including the end day; the start day is not checked.
  bool isActiveOn(DateTime day) => dayDifference(day, end) <= 0;

  /// R3: dashboard also requires the status to have started.
  bool isCurrentOnDashboard(DateTime day) =>
      isActiveOn(day) && dayDifference(start, day) <= 0;

  DateTime get bookOutAt => DateTime(start.year, start.month, start.day, 0, 30);
  DateTime get bookInAt => DateTime(end.year, end.month, end.day, 22);

  /// R21: Leave and Medical Appointment book the soldier out and back in.
  List<LinkedAttendance> get linkedAttendance => isExcuse
      ? const []
      : [
          (at: bookOutAt, isInsideCamp: false),
          (at: bookInAt, isInsideCamp: true),
        ];

  Status copyWith({
    String? id,
    String? soldierId,
    String? type,
    String? name,
    DateTime? start,
    DateTime? end,
    String? startAttendanceId,
    String? endAttendanceId,
  }) =>
      Status(
        id: id ?? this.id,
        soldierId: soldierId ?? this.soldierId,
        type: type ?? this.type,
        name: name ?? this.name,
        start: start ?? this.start,
        end: end ?? this.end,
        startAttendanceId: startAttendanceId ?? this.startAttendanceId,
        endAttendanceId: endAttendanceId ?? this.endAttendanceId,
      );

  @override
  List<Object?> get props => [
        id,
        soldierId,
        type,
        name,
        start,
        end,
        startAttendanceId,
        endAttendanceId,
      ];
}

/// Splits into active (R2) and past statuses for the statuses tab.
({List<Status> active, List<Status> past}) partitionStatuses(
  Iterable<Status> statuses,
  DateTime today,
) {
  final active = <Status>[];
  final past = <Status>[];
  for (final status in statuses) {
    (status.isActiveOn(today) ? active : past).add(status);
  }
  return (active: active, past: past);
}
