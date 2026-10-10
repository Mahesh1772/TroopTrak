import 'package:flutter_test/flutter_test.dart';

List<String> non_participants = [];

List<Map<String, dynamic>> statusList = [
  {'statusType': 'Excuse', 'statusName': 'Ex Uniform', 'Name': 'John'},
  {'statusType': 'Leave', 'Name': 'Jane'},
  {
    'statusType': 'Medical Appointment',
    'statusName': 'National Skin Center',
    'Name': 'Doe'
  },
  {
    'statusType': 'Medical Appointment',
    'statusName': 'Ex Boots',
    'Name': 'Bob'
  },
];

List<String> guardDuty = ['Ex Uniform', 'Ex Boots'];

void autoFilter() {
  //non_participants = [];
  print(statusList);
  for (var status in statusList) {
    if (status['statusType'] == 'Excuse') {
      if (guardDuty.contains(status['statusName'])) {
        non_participants.add(status['Name']);
      }
    } else if (status['statusType'] == 'Leave') {
      non_participants.add(status['Name']);
    }
  }
}

void main() {
  test('autoFilter test', () {
    autoFilter();
    expect(non_participants.length, equals(2));
  });
}
