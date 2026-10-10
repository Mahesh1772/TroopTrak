import 'package:equatable/equatable.dart';

import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/entities/status.dart';

class StrengthSummary extends Equatable {
  const StrengthSummary({
    required this.officers,
    required this.woses,
    required this.onStatus,
    required this.onMa,
  });

  /// R4 groups; soldiers with an unknown rank are in neither, as the source.
  final List<Soldier> officers;
  final List<Soldier> woses;

  /// R3: started on or before today and still active; once per soldier (K3).
  final List<Soldier> onStatus;
  final List<Soldier> onMa;

  List<Soldier> get officersInCamp => [
        for (final s in officers)
          if (s.isInCamp) s,
      ];

  List<Soldier> get wosesInCamp => [
        for (final s in woses)
          if (s.isInCamp) s,
      ];

  int get total => officers.length + woses.length;

  @override
  List<Object?> get props => [officers, woses, onStatus, onMa];
}

/// Pure dashboard rule: in-camp comes from [soldiers] (already R21-resolved).
StrengthSummary buildStrengthSummary(
  List<Soldier> soldiers,
  Iterable<Status> statuses,
  DateTime today,
) {
  final maIds = <String>{};
  final statusIds = <String>{};
  for (final s in statuses) {
    if (!s.isCurrentOnDashboard(today)) continue;
    (s.isMedicalAppointment ? maIds : statusIds).add(s.soldierId);
  }
  return StrengthSummary(
    officers: [
      for (final s in soldiers)
        if (s.isOfficer) s,
    ],
    woses: [
      for (final s in soldiers)
        if (s.isWose) s,
    ],
    onStatus: [
      for (final s in soldiers)
        if (statusIds.contains(s.id)) s,
    ],
    onMa: [
      for (final s in soldiers)
        if (maIds.contains(s.id)) s,
    ],
  );
}
