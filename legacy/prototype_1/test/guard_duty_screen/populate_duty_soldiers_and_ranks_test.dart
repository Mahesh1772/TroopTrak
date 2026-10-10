import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> dutySoldiersAndRanks = {};

void populateDutySoldiersAndRanksArray() {
  var length = dutySoldiersAndRanks.length;

  for (var i = length; i < 10; i++) {
    dutySoldiersAndRanks.addEntries({'NA$i': 'NA'}.entries);
  }
}

void main() {
  group('populateDutySoldiersAndRanksArray', () {
    test('should add NA entries to the array if it has less than 10 items',
        () async {
      dutySoldiersAndRanks = {'John': 'PTE', 'Jane': '3SG', 'Bob': 'CPT'};

      populateDutySoldiersAndRanksArray();

      expect(dutySoldiersAndRanks.length, equals(10));
      expect(dutySoldiersAndRanks['NA3'], equals('NA'));
      expect(dutySoldiersAndRanks['NA9'], equals('NA'));
    });

    test("should not add NA entries to the array if it has exactly 10 items",
        () async {
      dutySoldiersAndRanks = {
        'John': 'PTE',
        'Jane': '3SG',
        'Bob': 'CPT',
        'Alice': 'MAJ',
        'Charlie': 'COL',
        'David': 'LG',
        'Eve': 'LTA',
        'Frank': 'MG',
        'Grace': 'BG',
        'Henry': 'LTC'
      };

      populateDutySoldiersAndRanksArray();

      expect(dutySoldiersAndRanks.length, equals(10));
      expect(dutySoldiersAndRanks['Alice'], equals('MAJ'));
      expect(dutySoldiersAndRanks['Henry'], equals('LTC'));

      for (var i = 0; i < dutySoldiersAndRanks.length; i++) {
        expect(dutySoldiersAndRanks.containsValue('NA'), isFalse);
      }
    });
  });
}
