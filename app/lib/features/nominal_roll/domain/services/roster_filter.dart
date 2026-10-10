import '../../../soldiers/domain/entities/soldier.dart';

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

/// R12: case-insensitive contains on the chosen field; the signed-in
/// commander ([excludeId], their `Users` doc id) is never listed.
List<Soldier> filterRoster(
  Iterable<Soldier> soldiers, {
  required String query,
  required SearchCategory category,
  String? excludeId,
}) {
  final q = query.toLowerCase();
  return [
    for (final s in soldiers)
      if (s.id != excludeId &&
          (q.isEmpty || category.valueOf(s).toLowerCase().contains(q)))
        s,
  ];
}
