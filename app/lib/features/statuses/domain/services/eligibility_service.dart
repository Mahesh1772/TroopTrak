import '../../../../core/constants/conduct_types.dart';
import '../entities/status.dart';

/// R5 / R6 exclusion rules. Lists are verbatim from the source, including the
/// inconsistent spellings (K1, preserved by user decision).
abstract final class EligibilityService {
  static const conductExcuses = <String, List<String>>{
    ConductTypes.run: ['Ex RMJ', 'Ex Lower Limb', 'LD'],
    ConductTypes.routeMarch: [
      'Ex RMJ',
      'Ex Heavy Loads',
      'Ex Lower Limbs',
      'LD',
      'Ex Uniform',
      'Ex Boots',
      'Ex FLEGs',
    ],
    ConductTypes.ippt: [
      'Ex Upper Limb',
      'LD',
      'Ex Lower Limb',
      'Ex RMJ',
      'Ex Pushup',
      'Ex Situp',
    ],
    ConductTypes.outfield: [
      'Ex Sunlight',
      'Ex grass',
      'Ex Outfield',
      'Ex Uniform',
      'Ex Boots',
    ],
    ConductTypes.strengthAndPower: ['Ex Upper Limb', 'LD'],
    ConductTypes.metabolicCircuit: ['Ex RMJ', 'Ex Lower Limb', 'LD'],
    ConductTypes.combatCircuit: [
      'Ex Uniform',
      'Ex Boots',
      'Ex RMJ',
      'Ex Heavy Loads',
      'Ex Lower Limb',
      'Ex FLEGs',
      'LD',
    ],
    ConductTypes.liveFiring: [
      'Ex FLEGS',
      'Ex Uniform',
      'Ex Boots',
      'LD',
      'Ex Lower Limb',
      'Ex RMJ',
    ],
    ConductTypes.socVoc: [
      'Ex Upper Limb',
      'LD',
      'Ex Lower Limb',
      'Ex RMJ',
      'Ex Uniform',
      'Ex Boots',
      'Ex FLEGS',
    ],
  };

  static const guardDutyExcuses = ['Ex Uniform', 'Ex Boots'];

  /// R5: soldierId → reason (status name) for statuses active on [today] (K2).
  /// When several statuses match, the last one wins, as in the source.
  static Map<String, String> conductExclusions(
    String conductType,
    Iterable<Status> statuses,
    DateTime today,
  ) {
    final excuses = conductExcuses[conductType] ?? const <String>[];
    final reasons = <String, String>{};
    for (final status in statuses) {
      if (!status.isActiveOn(today)) continue;
      if (status.isLeave ||
          (status.isExcuse && excuses.contains(status.name))) {
        reasons[status.soldierId] = status.name;
      }
    }
    return reasons;
  }

  /// R6: soldier ids that cannot be rostered for guard duty on [today].
  static Set<String> guardDutyExclusions(
    Iterable<Status> statuses,
    DateTime today,
  ) =>
      {
        for (final status in statuses)
          if (status.isActiveOn(today) &&
              (status.isLeave ||
                  (status.isExcuse && guardDutyExcuses.contains(status.name))))
            status.soldierId,
      };
}
