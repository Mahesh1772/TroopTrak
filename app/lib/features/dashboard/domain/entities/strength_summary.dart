import 'package:equatable/equatable.dart';

import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/services/parade_roster.dart';
import '../../../statuses/domain/services/parade_state.dart';

class StrengthSummary extends Equatable {
  const StrengthSummary({required this.entries});

  final List<ParadeEntry> entries;

  /// R4 groups; soldiers with an unknown rank are in neither, as the source.
  List<ParadeEntry> get officerEntries => [
        for (final e in entries)
          if (e.soldier.isOfficer) e,
      ];

  List<ParadeEntry> get woseEntries => [
        for (final e in entries)
          if (e.soldier.isWose) e,
      ];

  int get total => officerEntries.length + woseEntries.length;

  /// D9: an excuse still counts as in camp.
  int get inCampCount => _grouped.where((e) => e.state.isInCamp).length;

  /// Over officers and WOSEs, so the counts of all states add up to [total].
  int count(ParadeState state) =>
      _grouped.where((e) => e.state == state).length;

  List<Soldier> get officers => _soldiers(officerEntries);

  List<Soldier> get woses => _soldiers(woseEntries);

  List<Soldier> get officersInCamp =>
      _soldiers(officerEntries.where((e) => e.state.isInCamp));

  List<Soldier> get wosesInCamp =>
      _soldiers(woseEntries.where((e) => e.state.isInCamp));

  /// R3: a current non-MA status; once per soldier (K3).
  List<Soldier> get onStatus => _soldiers(
      entries.where((e) => e.statuses.any((s) => !s.isMedicalAppointment)));

  /// R3: a current MA status; once per soldier (K3).
  List<Soldier> get onMa => _soldiers(
      entries.where((e) => e.statuses.any((s) => s.isMedicalAppointment)));

  List<ParadeEntry> get _grouped => [...officerEntries, ...woseEntries];

  static List<Soldier> _soldiers(Iterable<ParadeEntry> entries) =>
      [for (final e in entries) e.soldier];

  @override
  List<Object?> get props => [entries];
}
