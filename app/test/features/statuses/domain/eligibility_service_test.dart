import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/constants/conduct_types.dart';
import 'package:trooptrak_final_application/core/constants/status_names.dart';
import 'package:trooptrak_final_application/features/statuses/domain/services/eligibility_service.dart';

import '../../../helpers/builders.dart';

void main() {
  final today = DateTime(2023, 7, 5, 9);

  Map<String, String> exclusions(String type, String statusType, String name,
          {DateTime? end}) =>
      EligibilityService.conductExclusions(
        type,
        [
          buildStatus(
              type: statusType, name: name, end: end ?? DateTime(2023, 7, 7))
        ],
        today,
      );

  group('conductExclusions (R5)', () {
    test('lists match the source verbatim', () {
      expect(EligibilityService.conductExcuses.keys, ConductTypes.all);
      expect(EligibilityService.conductExcuses[ConductTypes.liveFiring], [
        'Ex FLEGS',
        'Ex Uniform',
        'Ex Boots',
        'LD',
        'Ex Lower Limb',
        'Ex RMJ'
      ]);
      expect(EligibilityService.conductExcuses[ConductTypes.routeMarch],
          contains('Ex Lower Limbs'));
    });

    test('every listed excuse excludes for its conduct type', () {
      EligibilityService.conductExcuses.forEach((type, excuses) {
        for (final excuse in excuses) {
          expect(exclusions(type, 'Excuse', excuse), {'Tan Ah Kow': excuse},
              reason: '$type / $excuse');
        }
      });
    });

    test('every unlisted suggestion does not exclude for that type', () {
      EligibilityService.conductExcuses.forEach((type, excuses) {
        for (final name in StatusNames.suggestions) {
          if (excuses.contains(name)) continue;
          expect(exclusions(type, 'Excuse', name), isEmpty,
              reason: '$type / $name');
        }
      });
    });

    test('Leave excludes for every type, reason is the leave name', () {
      for (final type in [...ConductTypes.all, 'Something else']) {
        expect(exclusions(type, 'Leave', 'Annual Leave'),
            {'Tan Ah Kow': 'Annual Leave'});
      }
    });

    test('Medical Appointment never excludes', () {
      for (final type in ConductTypes.all) {
        expect(exclusions(type, 'Medical Appointment', 'LD'), isEmpty);
      }
    });

    test('an unknown conduct type excludes only Leave', () {
      expect(exclusions('Swimming', 'Excuse', 'LD'), isEmpty);
      expect(exclusions('Swimming', 'Leave', 'OL'), {'Tan Ah Kow': 'OL'});
    });

    test('K1 preserved: near-miss spellings do not match', () {
      expect(
          exclusions(ConductTypes.liveFiring, 'Excuse', 'Ex FLEGs'), isEmpty);
      expect(exclusions(ConductTypes.routeMarch, 'Excuse', 'Ex Lower Limb'),
          isEmpty);
      expect(exclusions(ConductTypes.run, 'Excuse', 'Ex RMJ '), isEmpty);
    });

    test('K2 preserved: uses statuses active today, start not checked', () {
      expect(
          exclusions(ConductTypes.run, 'Excuse', 'LD',
              end: DateTime(2023, 7, 5)),
          {'Tan Ah Kow': 'LD'});
      expect(
          exclusions(ConductTypes.run, 'Excuse', 'LD',
              end: DateTime(2023, 7, 4)),
          isEmpty);
      final future = EligibilityService.conductExclusions(
        ConductTypes.run,
        [
          buildStatus(
              name: 'LD',
              start: DateTime(2023, 8, 1),
              end: DateTime(2023, 8, 3))
        ],
        today,
      );
      expect(future, {'Tan Ah Kow': 'LD'});
    });

    test('several soldiers; the last matching status sets the reason', () {
      final result = EligibilityService.conductExclusions(
        ConductTypes.run,
        [
          buildStatus(id: '1', soldierId: 'A', name: 'LD'),
          buildStatus(id: '2', soldierId: 'A', name: 'Ex RMJ'),
          buildStatus(id: '3', soldierId: 'B', type: 'Leave', name: 'OL'),
          buildStatus(id: '4', soldierId: 'C', name: 'Ex Upper Limb'),
        ],
        today,
      );
      expect(result, {'A': 'Ex RMJ', 'B': 'OL'});
    });
  });

  group('guardDutyExclusions (R6)', () {
    test('active Ex Uniform, Ex Boots or any Leave exclude', () {
      final result = EligibilityService.guardDutyExclusions([
        buildStatus(soldierId: 'A', name: 'Ex Uniform'),
        buildStatus(soldierId: 'B', name: 'Ex Boots'),
        buildStatus(soldierId: 'C', type: 'Leave', name: 'OL'),
        buildStatus(soldierId: 'D', name: 'LD'),
        buildStatus(
            soldierId: 'E', type: 'Medical Appointment', name: 'Ex Boots'),
        buildStatus(
            soldierId: 'F', name: 'Ex Boots', end: DateTime(2023, 7, 4)),
      ], today);
      expect(result, {'A', 'B', 'C'});
    });
  });
}
