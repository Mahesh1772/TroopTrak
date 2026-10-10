import 'package:flutter_test/flutter_test.dart';
import 'package:trooptrak_final_application/features/soldiers/data/models/soldier_model.dart';

import '../../../helpers/builders.dart';

void main() {
  test('fromMap reads every Appendix B Users field', () {
    final soldier = SoldierModel.fromMap('Tan Ah Kow', soldierDoc(points: 2.5));
    expect(soldier, buildSoldier(points: 2.5));
  });

  test('round-trips through toCreateMap with exact field names', () {
    final map = SoldierModel.toCreateMap(buildSoldier(points: 1));
    expect(map, {
      'name': 'Tan Ah Kow',
      'rank': 'CPL',
      'company': 'Alpha',
      'platoon': '1',
      'section': '2',
      'appointment': 'Section IC',
      'rationType': 'NM',
      'bloodgroup': 'O+',
      'dob': '5 Jul 2000',
      'enlistment': '1 Jan 2023',
      'ord': '1 Jan 2025',
      'currentAttendance': 'Inside Camp',
      'points': 1.0,
    });
    expect(SoldierModel.fromMap('Tan Ah Kow', map), buildSoldier(points: 1));
  });

  test('toProfileMap leaves attendance and points out', () {
    final map = SoldierModel.toProfileMap(buildSoldier());
    expect(map.containsKey('currentAttendance'), isFalse);
    expect(map.containsKey('points'), isFalse);
  });

  test('currentAttendance Outside means not in camp; anything else is in camp',
      () {
    expect(
        SoldierModel.fromMap('a', soldierDoc(currentAttendance: 'Outside'))
            .isInCamp,
        isFalse);
    expect(SoldierModel.fromMap('a', soldierDoc()).isInCamp, isTrue);
    expect(SoldierModel.fromMap('a', {'name': 'a'}).isInCamp, isTrue);
    expect(SoldierModel.attendanceValue(false), 'Outside');
  });

  test('tolerates missing fields and int or string points', () {
    final sparse = SoldierModel.fromMap('Doc Id', {'points': 3});
    expect(sparse.name, 'Doc Id');
    expect(sparse.rank, '');
    expect(sparse.dob, isNull);
    expect(sparse.points, 3.0);
    expect(SoldierModel.fromMap('a', {'points': '1.5'}).points, 1.5);
    expect(SoldierModel.fromMap('a', {'points': 'x'}).points, 0);
    expect(SoldierModel.fromMap('a', {'dob': 'garbage'}).dob, isNull);
  });
}
