enum RankGroup {
  enlisted,
  specialistCadet,
  specialist,
  warrantOfficer,
  officerCadet,
  juniorOfficer,
  seniorOfficer,
  unknown,
}

abstract final class Ranks {
  static const enlisted = ['REC', 'PTE', 'LCP', 'CPL', 'CFC'];
  static const specialists = ['3SG', '2SG', '1SG', 'SSG', 'MSG'];
  static const warrantOfficers = ['3WO', '2WO', '1WO', 'MWO', 'SWO', 'CWO'];
  static const officers = [
    '2LT',
    'LTA',
    'CPT',
    'MAJ',
    'LTC',
    'SLTC',
    'COL',
    'BG',
    'MG',
    'LG',
  ];

  /// Dashboard "WOSEs" group: everyone who is not an officer.
  static const woses = [
    'REC',
    'PTE',
    'LCP',
    'CPL',
    'CFC',
    'SCT',
    'OCT',
    '3SG',
    '2SG',
    '1SG',
    'SSG',
    'MSG',
    '3WO',
    '2WO',
    '1WO',
    'MWO',
    'SWO',
    'CWO',
  ];

  /// Commander add/edit soldier list, in source order.
  static const all = [
    'REC',
    'PTE',
    'LCP',
    'CPL',
    'CFC',
    'SCT',
    '3SG',
    '2SG',
    '1SG',
    'SSG',
    'MSG',
    '3WO',
    '2WO',
    '1WO',
    'MWO',
    'SWO',
    'CWO',
    'OCT',
    '2LT',
    'LTA',
    'CPT',
    'MAJ',
    'LTC',
    'SLTC',
    'COL',
    'BG',
    'MG',
    'LG',
  ];

  static const commanderRegistration = [
    '3SG',
    '2SG',
    '1SG',
    'SSG',
    'MSG',
    '3WO',
    '2WO',
    '1WO',
    'MWO',
    'SWO',
    'CWO',
    '2LT',
    'LTA',
    'CPT',
    'MAJ',
    'LTC',
    'SLTC',
    'COL',
    'BG',
    'MG',
    'LG',
  ];

  static const soldierRegistration = [
    'REC',
    'PTE',
    'LCP',
    'CPL',
    'CFC',
    'SCT',
    'OCT',
  ];

  static bool isOfficer(String rank) => officers.contains(_norm(rank));

  static bool isWose(String rank) => woses.contains(_norm(rank));

  static RankGroup groupOf(String rank) {
    final r = _norm(rank);
    if (enlisted.contains(r)) return RankGroup.enlisted;
    if (r == 'SCT') return RankGroup.specialistCadet;
    if (specialists.contains(r)) return RankGroup.specialist;
    if (warrantOfficers.contains(r)) return RankGroup.warrantOfficer;
    if (r == 'OCT') return RankGroup.officerCadet;
    if (const ['2LT', 'LTA', 'CPT'].contains(r)) return RankGroup.juniorOfficer;
    if (officers.contains(r)) return RankGroup.seniorOfficer;
    return RankGroup.unknown;
  }

  static String _norm(String rank) => rank.trim().toUpperCase();
}
