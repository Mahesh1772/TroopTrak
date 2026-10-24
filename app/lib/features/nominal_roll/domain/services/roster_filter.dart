import '../../../soldiers/domain/entities/soldier.dart';
import '../../../statuses/domain/services/parade_roster.dart';

/// R12 search chips, in source order, with the Users field each one reads.
enum SearchCategory {
  name('Name'),
  rank('Rank'),
  company('Company'),
  section('Section'),
  platoon('Platoon'),
  ration('Ration'),
  blood('Blood'),
  appointment('Appointment');

  const SearchCategory(this.label);

  final String label;

  String valueOf(Soldier s) => switch (this) {
        name => s.name,
        rank => s.rank,
        company => s.company,
        section => s.section,
        platoon => s.platoon,
        ration => s.rationType,
        blood => s.bloodGroup,
        appointment => s.appointment,
      };
}

/// R12: case-insensitive contains on the chosen field.
List<ParadeEntry> filterRoster(
  Iterable<ParadeEntry> entries, {
  required String query,
  required SearchCategory category,
}) {
  final q = query.toLowerCase();
  return [
    for (final entry in entries)
      if (q.isEmpty ||
          category.valueOf(entry.soldier).toLowerCase().contains(q))
        entry,
  ];
}
