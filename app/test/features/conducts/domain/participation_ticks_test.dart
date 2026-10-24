import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/features/conducts/domain/services/participation_ticks.dart';

import '../../../helpers/builders.dart';

void main() {
  final tan = buildSoldier(name: 'Tan');
  final lee = buildSoldier(name: 'Lee');
  final lim = buildSoldier(name: 'Lim');
  final roster = [tan, lee, lim];

  ParticipationTicks ticksOf(
    List<String> participants, {
    String? selfName,
  }) =>
      participationTicks(
        roster: roster,
        conduct: buildConduct(participants: participants),
        selfName: selfName,
      );

  test('an empty roster has no ticks and zero counts', () {
    final ticks = participationTicks(
      roster: const [],
      conduct: buildConduct(participants: ['Tan']),
    );
    expect(ticks.ticks, isEmpty);
    expect(ticks.total, 0);
    expect(ticks.participating, 0);
    expect(ticks.notParticipating, 0);
    expect(ticks.self, isNull);
  });

  test('nobody took part: every tick is out', () {
    final ticks = ticksOf([]);
    expect(ticks.ticks.every((t) => !t.tookPart), isTrue);
    expect(ticks.participating, 0);
    expect(ticks.notParticipating, 3);
    expect(ticks.total, 3);
  });

  test('everyone took part', () {
    final ticks = ticksOf(['Tan', 'Lee', 'Lim']);
    expect(ticks.ticks.every((t) => t.tookPart), isTrue);
    expect(ticks.participating, 3);
    expect(ticks.notParticipating, 0);
  });

  test('ticks follow the roster order, not the participant order', () {
    final ticks = ticksOf(['Lim', 'Tan']);
    expect(ticks.ticks.map((t) => t.soldier), [tan, lee, lim]);
    expect(ticks.ticks.map((t) => t.tookPart), [true, false, true]);
    expect(ticks.participating, 2);
    expect(ticks.notParticipating, 1);
  });

  test('no signed-in soldier marks no tick as self', () {
    final ticks = ticksOf(['Tan']);
    expect(ticks.ticks.any((t) => t.isSelf), isFalse);
    expect(ticks.self, isNull);
  });

  test('the signed-in soldier is marked whether they took part or not', () {
    final took = ticksOf(['Tan', 'Lee'], selfName: 'Lee');
    expect(took.ticks.map((t) => t.isSelf), [false, true, false]);
    expect(took.self?.soldier, lee);
    expect(took.self?.tookPart, isTrue);

    final missed = ticksOf(['Tan'], selfName: 'Lee');
    expect(missed.self?.soldier, lee);
    expect(missed.self?.tookPart, isFalse);
  });

  test('a signed-in soldier missing from the roster marks nothing', () {
    expect(ticksOf(['Tan'], selfName: 'Ong').self, isNull);
  });

  test('participants who are not on the roster are not counted', () {
    final ticks = ticksOf(['Tan', 'Ghost']);
    expect(ticks.total, 3);
    expect(ticks.participating, 1);
  });

  group('participationTicksOf', () {
    test('ticks follow the roster; a name in the list is a tick that took part',
        () {
      final ticks = participationTicksOf(
        roster: roster,
        participants: ['Lim', 'Tan'],
      );
      expect(ticks.ticks.map((t) => t.soldier), [tan, lee, lim]);
      expect(ticks.ticks.map((t) => t.tookPart), [true, false, true]);
      expect(ticks.participating, 2);
      expect(ticks.total, 3);
    });

    test('names off the roster are ignored; no participants is all out', () {
      expect(
        participationTicksOf(roster: roster, participants: ['Ghost'])
            .participating,
        0,
      );
      expect(participationTicksOf(roster: roster, participants: []).total, 3);
    });

    test('an empty roster has no ticks even with participants', () {
      final ticks =
          participationTicksOf(roster: const [], participants: ['Tan']);
      expect([ticks.total, ticks.participating], [0, 0]);
    });

    test('agrees with participationTicks for a conduct', () {
      expect(
        participationTicksOf(roster: roster, participants: ['Tan', 'Lee']),
        ticksOf(['Tan', 'Lee']),
      );
    });
  });
}
