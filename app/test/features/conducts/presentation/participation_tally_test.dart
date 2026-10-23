import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/core/widgets/state_tone.dart';
import 'package:trooptrak_final_application/features/conducts/domain/services/participation_ticks.dart';
import 'package:trooptrak_final_application/features/conducts/presentation/widgets/participation_tally.dart';

import '../../../helpers/builders.dart';

void main() {
  final roster = [
    buildSoldier(name: 'A', rank: 'CPT'),
    buildSoldier(name: 'B', rank: 'PTE'),
    buildSoldier(name: 'C', rank: '3SG'),
  ];
  final conduct = buildConduct(participants: ['A', 'C']);

  test('took part is accent, did not is out, in roster order', () {
    final ticks = participationTallyTicks(
        participationTicks(roster: roster, conduct: conduct));
    expect(ticks.map((t) => t.tone),
        [StateTone.accent, StateTone.out, StateTone.accent]);
  });

  test('the title is the rank and name and the detail the part played', () {
    final ticks = participationTallyTicks(
        participationTicks(roster: roster, conduct: conduct));
    expect(ticks.map((t) => t.title), ['CPT A', 'PTE B', '3SG C']);
    expect(ticks.map((t) => t.detail),
        ['participating', 'not participating', 'participating']);
  });

  test('no tick is the signed-in soldier\'s without a name', () {
    final ticks = participationTallyTicks(
        participationTicks(roster: roster, conduct: conduct));
    expect(ticks.any((t) => t.isSelf), isFalse);
  });

  test('only the named soldier\'s tick is ringed, took part or not', () {
    for (final name in ['A', 'B']) {
      final ticks = participationTallyTicks(
          participationTicks(roster: roster, conduct: conduct, selfName: name));
      expect([for (final t in ticks) t.isSelf],
          [for (final s in roster) s.name == name]);
    }
  });

  test('an empty roster gives no ticks', () {
    expect(
        participationTallyTicks(
            participationTicks(roster: const [], conduct: conduct)),
        isEmpty);
  });
}
