import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/entities/nominal_roll.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/services/roster_filter.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/parade_roster.dart';

import '../../helpers/builders.dart';

void main() {
  final tan = buildSoldier(name: 'Tan Ah Kow', rank: 'CPL');
  final lee = buildSoldier(
      name: 'Lee Wei',
      rank: '2LT',
      company: 'Bravo',
      platoon: '3',
      section: '4',
      appointment: 'Platoon Commander',
      rationType: 'SD VC',
      bloodGroup: 'AB-',
      isInCamp: false);
  final me = buildSoldier(name: 'Cmd Lim', rank: 'CPT');
  final entries = paradeRoster([tan, lee, me], const [], DateTime(2023, 7, 5));

  group('filterRoster (R12)', () {
    for (final (category, query, expected) in [
      (SearchCategory.name, 'tan ah', 'Tan Ah Kow'),
      (SearchCategory.rank, '2lt', 'Lee Wei'),
      (SearchCategory.company, 'BRAVO', 'Lee Wei'),
      (SearchCategory.section, '4', 'Lee Wei'),
      (SearchCategory.platoon, '3', 'Lee Wei'),
      (SearchCategory.ration, 'vc', 'Lee Wei'),
      (SearchCategory.blood, 'ab-', 'Lee Wei'),
      (SearchCategory.appointment, 'platoon', 'Lee Wei'),
    ]) {
      test('${category.label} searches its own field', () {
        expect(
            filterRoster(entries, query: query, category: category)
                .map((e) => e.soldier.name),
            [expected]);
      });
    }

    test('an empty query keeps every entry in order', () {
      expect(filterRoster(entries, query: '', category: SearchCategory.name),
          entries);
    });

    test('chip labels follow the source order', () {
      expect(SearchCategory.values.map((c) => c.label), [
        'Name',
        'Rank',
        'Company',
        'Section',
        'Platoon',
        'Ration',
        'Blood',
        'Appointment',
      ]);
    });
  });

  group('NominalRoll', () {
    test('never lists the signed-in commander (R12)', () {
      final roll = NominalRoll(entries, excludeId: 'Cmd Lim');
      expect(roll.entries.map((e) => e.soldier), [tan, lee]);
      expect(roll.total, 2);
    });

    test('lists everyone when there is no signed-in commander', () {
      expect(NominalRoll(entries).total, 3);
    });

    test('bookedIn counts the soldiers booked in', () {
      final roll = NominalRoll(entries, excludeId: 'Cmd Lim');
      expect(roll.bookedIn, 1);
      expect(NominalRoll(entries).bookedIn, 2);
    });

    test('bookedIn counts a soldier on a status who is booked in', () {
      final onLeave = paradeRoster(
        [tan],
        [
          buildStatus(
              type: 'Leave',
              name: 'Annual Leave',
              start: DateTime(2023, 7, 1),
              end: DateTime(2023, 7, 9)),
        ],
        DateTime(2023, 7, 5),
      );
      expect(NominalRoll(onLeave).bookedIn, 1);
    });

    test('an empty roll has nothing booked in', () {
      final roll = NominalRoll(const []);
      expect([roll.total, roll.bookedIn], [0, 0]);
    });

    test('search narrows the entries by the chosen field', () {
      final roll = NominalRoll(entries, excludeId: 'Cmd Lim');
      expect(roll.search('bravo', SearchCategory.company).map((e) => e.soldier),
          [lee]);
      expect(roll.search('bravo', SearchCategory.name), isEmpty);
    });
  });
}
