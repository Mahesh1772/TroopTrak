import 'package:flutter_test/flutter_test.dart';

/// Returns the difference (in full days) between the provided date and today.
int calculateDifference(DateTime date, DateTime selectedDate) {
  //DateTime now = DateTime.now();
  return DateTime(date.year, date.month, date.day)
      .difference(
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day))
      .inDays;
}

void main() {
  test('calculateDifference returns negative difference for past dates', () {
    final DateTime date1 = DateTime(2023, 7, 16);
    final DateTime date2 = DateTime(2023, 7, 20);
    const int expectedDifference = -4;

    expect(calculateDifference(date1, date2), expectedDifference);
  });

  test('calculateDifference returns correct difference in full days', () {
    final DateTime date1 = DateTime(2023, 7, 20);
    final DateTime date2 = DateTime(2023, 7, 16);
    const int expectedDifference = 4;

    expect(calculateDifference(date1, date2), expectedDifference);
  });

  test('calculateDifference returns zero for same dates', () {
    final DateTime date1 = DateTime(2023, 7, 16);
    final DateTime date2 = DateTime(2023, 7, 16);
    const int expectedDifference = 0;

    expect(calculateDifference(date1, date2), expectedDifference);
  });
}
