import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_formats.dart';
import '../../../soldiers/domain/entities/soldier.dart';
import '../entities/status.dart';
import 'parade_state.dart';

/// One soldier on the parade state: current statuses, primary first, and the
/// state they imply.
class ParadeEntry extends Equatable {
  const ParadeEntry({
    required this.soldier,
    required this.statuses,
    required this.state,
  });

  final Soldier soldier;
  final List<Status> statuses;
  final ParadeState state;

  Status? get status => statuses.firstOrNull;

  @override
  List<Object?> get props => [soldier, statuses, state];
}

/// Soldiers keep their order. A status counts while it is current (R3).
List<ParadeEntry> paradeRoster(
  Iterable<Soldier> soldiers,
  Iterable<Status> statuses,
  DateTime today,
) {
  final current = <String, List<Status>>{};
  for (final status in statuses) {
    if (status.isCurrentOnDashboard(today)) {
      (current[status.soldierId] ??= []).add(status);
    }
  }
  return [
    for (final soldier in soldiers) _entryFor(soldier, current[soldier.id]),
  ];
}

ParadeEntry _entryFor(Soldier soldier, List<Status>? current) {
  final statuses = _primaryFirst(current ?? const []);
  return ParadeEntry(
    soldier: soldier,
    statuses: statuses,
    state: paradeStateOf(soldier, statuses.firstOrNull),
  );
}

/// Leave, then Medical Appointment, then Excuse; within a type the one that
/// ends last. Ties keep the input order.
List<Status> _primaryFirst(List<Status> current) {
  final ranked = current.indexed.toList()
    ..sort((a, b) {
      final (i, first) = a;
      final (j, second) = b;
      final byType = _precedence(first) - _precedence(second);
      if (byType != 0) return byType;
      final byEnd = dayDifference(second.end, first.end);
      return byEnd != 0 ? byEnd : i - j;
    });
  return [for (final (_, status) in ranked) status];
}

int _precedence(Status status) => switch (status) {
      Status(isLeave: true) => 0,
      Status(isMedicalAppointment: true) => 1,
      Status(isExcuse: true) => 2,
      _ => 3,
    };
