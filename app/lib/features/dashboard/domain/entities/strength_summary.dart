import 'package:equatable/equatable.dart';

import '../../../statuses/domain/entities/status.dart';
import '../../../statuses/domain/services/parade_roster.dart';
import '../../../statuses/domain/services/parade_state.dart';

/// The two groups of the parade card, in the order of its tally strip.
enum ParadeGroup { officers, woses }

enum ParadeReportKind { officers, woses, onStatus, onMa }

final _inCampStates = {
  for (final state in ParadeState.values)
    if (state.isInCamp) state,
};

/// One expandable line of the parade report: the soldiers it lists and its
/// figure, `current` out of `total` when it has one.
class ParadeReportRow extends Equatable {
  const ParadeReportRow({
    required this.kind,
    required this.entries,
    required this.current,
    this.total,
  });

  final ParadeReportKind kind;
  final List<ParadeEntry> entries;
  final int current;
  final int? total;

  /// The states whose ticks in [group] this row stands for.
  Set<ParadeState> highlightedStates(ParadeGroup group) => switch (kind) {
        ParadeReportKind.officers when group == ParadeGroup.officers =>
          _inCampStates,
        ParadeReportKind.woses when group == ParadeGroup.woses => _inCampStates,
        ParadeReportKind.onStatus => {ParadeState.excuse, ParadeState.leave},
        ParadeReportKind.onMa => {ParadeState.medical},
        _ => const {},
      };

  /// The status this row names beside [entry]; `null` shows its state.
  Status? statusOf(ParadeEntry entry) => switch (kind) {
        ParadeReportKind.onStatus =>
          entry.statuses.where((s) => !s.isMedicalAppointment).firstOrNull,
        ParadeReportKind.onMa =>
          entry.statuses.where((s) => s.isMedicalAppointment).firstOrNull,
        _ => entry.status,
      };

  /// The status name beside [entry], else the name of its state.
  String labelOf(ParadeEntry entry) =>
      statusOf(entry)?.name ?? entry.state.label;

  @override
  List<Object?> get props => [kind, entries, current, total];
}

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

  /// Officers in tick-strip order: [ParadeState] order, the input order within.
  List<ParadeEntry> get officersByState => _byState(officerEntries);

  List<ParadeEntry> get wosesByState => _byState(woseEntries);

  int get total => officerEntries.length + woseEntries.length;

  /// D9: an excuse still counts as in camp.
  int get inCampCount => _grouped.where((e) => e.state.isInCamp).length;

  /// Over officers and WOSEs, so the counts of all states add up to [total].
  int count(ParadeState state) =>
      _grouped.where((e) => e.state == state).length;

  /// Officers, WOSEs, then R3 statuses and MAs, once per soldier (K3).
  List<ParadeReportRow> get rows {
    final officers = officerEntries;
    final woses = woseEntries;
    final onStatus = [
      for (final e in entries)
        if (e.statuses.any((s) => !s.isMedicalAppointment)) e,
    ];
    final onMa = [
      for (final e in entries)
        if (e.statuses.any((s) => s.isMedicalAppointment)) e,
    ];
    return [
      ParadeReportRow(
        kind: ParadeReportKind.officers,
        entries: officers,
        current: _inCamp(officers),
        total: officers.length,
      ),
      ParadeReportRow(
        kind: ParadeReportKind.woses,
        entries: woses,
        current: _inCamp(woses),
        total: woses.length,
      ),
      ParadeReportRow(
        kind: ParadeReportKind.onStatus,
        entries: onStatus,
        current: onStatus.length,
      ),
      ParadeReportRow(
        kind: ParadeReportKind.onMa,
        entries: onMa,
        current: onMa.length,
      ),
    ];
  }

  ParadeReportRow row(ParadeReportKind kind) =>
      rows.firstWhere((r) => r.kind == kind);

  List<ParadeEntry> get _grouped => [...officerEntries, ...woseEntries];

  static int _inCamp(List<ParadeEntry> entries) =>
      entries.where((e) => e.state.isInCamp).length;

  static List<ParadeEntry> _byState(List<ParadeEntry> entries) => [
        for (final state in ParadeState.values)
          ...entries.where((e) => e.state == state),
      ];

  @override
  List<Object?> get props => [entries];
}
