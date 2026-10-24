import 'package:equatable/equatable.dart';

import '../../../statuses/domain/services/parade_roster.dart';
import '../services/roster_filter.dart';

/// Every soldier on the roll except the signed-in commander ([excludeId], their
/// `Users` doc id), in the order given.
class NominalRoll extends Equatable {
  NominalRoll(Iterable<ParadeEntry> entries, {String? excludeId})
      : entries = List.unmodifiable([
          for (final entry in entries)
            if (entry.soldier.id != excludeId) entry,
        ]);

  final List<ParadeEntry> entries;

  int get total => entries.length;

  /// Booked in by the soldier's own flag, whatever status they are on.
  int get bookedIn => entries.where((e) => e.soldier.isInCamp).length;

  List<ParadeEntry> search(String query, SearchCategory category) =>
      filterRoster(entries, query: query, category: category);

  @override
  List<Object?> get props => [entries];
}
