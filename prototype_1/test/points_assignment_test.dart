import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

double points = 0;
String typeOfDay = "";
String dutyDate = "";

void pointsAssignment(DateTime value) {
  if (dutyDate != "Date of Duty:") {
    int nowDay = value.weekday;

    if (nowDay < 5) {
      points = 1;
      typeOfDay = "Weekday Duty 🫣";
    } else if (nowDay == 5) {
      points = 1.5;
      typeOfDay = "Weekday (Friday) Duty 😖";
    } else if (nowDay == 6) {
      points = 2.5;
      typeOfDay = "Weekend (Saturday) Duty 😵‍💫";
    } else if (nowDay == 7) {
      points = 2;
      typeOfDay = "Weekday (Sunday) Duty 🤧";
    }
  } else {
    points = 0;
    typeOfDay = "Select a duty date! 😄";
  }
}

void main() {
  group('pointsAssignment', () {
    test('should assign points and type for weekday duty', () {
      DateTime value = DateFormat('yyyy-MM-dd').parse('2023-06-26'); // A Monday
      pointsAssignment(value);
      expect(points, 1);
      expect(typeOfDay, 'Weekday Duty 🫣');
    });

    test('should assign points and type for Friday duty', () {
      DateTime value = DateFormat('yyyy-MM-dd').parse('2023-06-30'); // A Friday
      pointsAssignment(value);
      expect(points, 1.5);
      expect(typeOfDay, 'Weekday (Friday) Duty 😖');
    });

    test('should assign points and type for Saturday duty', () {
      DateTime value =
          DateFormat('yyyy-MM-dd').parse('2023-07-01'); // A Saturday
      pointsAssignment(value);
      expect(points, 2.5);
      expect(typeOfDay, 'Weekend (Saturday) Duty 😵‍💫');
    });

    test('should assign points and type for Sunday duty', () {
      DateTime value = DateFormat('yyyy-MM-dd').parse('2023-07-02'); // A Sunday
      pointsAssignment(value);
      expect(points, 2);
      expect(typeOfDay, 'Weekday (Sunday) Duty 🤧');
    });

    test('should assign 0 points and proper type when no duty date selected',
        () {
      DateTime value = DateTime.now(); // Any date
      dutyDate = 'Date of Duty:';
      pointsAssignment(value);
      expect(points, 0);
      expect(typeOfDay, 'Select a duty date! 😄');
    });
  });
}
