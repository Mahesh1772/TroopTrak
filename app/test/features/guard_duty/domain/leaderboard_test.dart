import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/features/guard_duty/domain/services/leaderboard.dart';

import '../../../helpers/builders.dart';

void main() {
  final tan = buildSoldier(name: 'Tan Ah Kow', points: 2);
  final lee = buildSoldier(name: 'Lee Wei', points: 5.5);

  group('Leaderboard.topPoints', () {
    test('is the highest score', () {
      expect(Leaderboard.topPoints([tan, lee]), 5.5);
    });

    test('is 0 for nobody', () {
      expect(Leaderboard.topPoints(const []), 0);
    });
  });

  group('Leaderboard.barFraction', () {
    test('is the share of the top score', () {
      expect(Leaderboard.barFraction(5.5, 5.5), 1);
      expect(Leaderboard.barFraction(2, 8), 0.25);
      expect(Leaderboard.barFraction(0, 8), 0);
    });

    test('is 0 when nobody has scored, not NaN', () {
      expect(Leaderboard.barFraction(0, 0), 0);
    });

    test('stays within 0 and 1', () {
      expect(Leaderboard.barFraction(9, 4), 1);
      expect(Leaderboard.barFraction(-1, 4), 0);
    });
  });

  group('Leaderboard.isSelf', () {
    test('matches the signed-in soldier by name', () {
      expect(Leaderboard.isSelf(tan, 'Tan Ah Kow'), isTrue);
      expect(Leaderboard.isSelf(lee, 'Tan Ah Kow'), isFalse);
    });

    test('is false for the commander, who has no name to match', () {
      expect(Leaderboard.isSelf(tan, null), isFalse);
      expect(Leaderboard.isSelf(tan, ''), isFalse);
    });
  });
}
