import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/features/soldiers/domain/entities/soldier.dart';

import '../../../helpers/builders.dart';

void main() {
  test('soldiers with the same fields are equal', () {
    expect(buildSoldier(), buildSoldier());
    expect(buildSoldier(), isNot(buildSoldier(points: 1)));
    expect(buildSoldier(), isNot(buildSoldier(isInCamp: false)));
  });

  test('defaults: in camp with zero points', () {
    const soldier = Soldier(id: 'x', name: 'x', rank: 'PTE');
    expect(soldier.isInCamp, isTrue);
    expect(soldier.points, 0);
    expect(soldier.dob, isNull);
  });

  test('copyWith replaces only given fields', () {
    final soldier = buildSoldier();
    final moved = soldier.copyWith(isInCamp: false, points: 2.5);
    expect(moved.isInCamp, isFalse);
    expect(moved.points, 2.5);
    expect(moved.copyWith(isInCamp: true, points: 0), soldier);
  });

  test('rank group helpers follow R4', () {
    expect(buildSoldier(rank: 'CPT').isOfficer, isTrue);
    expect(buildSoldier(rank: 'CPT').isWose, isFalse);
    expect(buildSoldier(rank: '3SG').isWose, isTrue);
  });

  test('pointsAfter clamps at zero (R9)', () {
    expect(Soldier.pointsAfter(2, 1.5), 3.5);
    expect(Soldier.pointsAfter(2, -1.5), 0.5);
    expect(Soldier.pointsAfter(1, -2.5), 0);
  });
}
