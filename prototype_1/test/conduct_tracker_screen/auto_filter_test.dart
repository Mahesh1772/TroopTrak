// All this was supposed to be in another file
import 'package:flutter_test/flutter_test.dart';

List<Map<String, dynamic>> statusList = [
  {'statusType': 'Excuse', 'statusName': 'Ex Uniform', 'Name': 'John'},
  {'statusType': 'Leave', 'Name': 'Jane'},
  {
    'statusType': 'Medical Appointment',
    'statusName': 'National Skin Center',
    'Name': 'Doe'
  },
  {'statusType': 'Excuse', 'statusName': 'Ex Uniform', 'Name': 'John'},
  {'statusType': 'Excuse', 'statusName': 'LD', 'Name': 'Bob'},
  {'statusType': 'Excuse', 'statusName': 'Ex Sunlight', 'Name': 'Alice'},
  {'statusType': 'Excuse', 'statusName': 'Ex grass', 'Name': 'Charlie'},
  {'statusType': 'Excuse', 'statusName': 'Ex Outfield', 'Name': 'Eve'},
  {'statusType': 'Excuse', 'statusName': 'Ex Boots', 'Name': 'Frank'},
];

List<String> Outfield = [
  'Ex Sunlight',
  'Ex grass',
  'Ex Outfield',
  'Ex Uniform',
  'Ex Boots'
];
List<String> Run = ['Ex RMJ', 'Ex Lower Limb', 'LD'];
List<String> S_P = ['Ex Upper Limb', 'LD'];
List<String> Imt = ['Ex FLEGS', 'Ex Uniform', 'Ex Boots', 'LD'];
List<String> Atp = [
  'Ex FLEGS',
  'Ex Uniform',
  'Ex Boots',
  'LD',
  'Ex Lower Limb',
  'Ex RMJ'
];
List<String> Ippt = [
  'Ex Upper Limb',
  'LD',
  'Ex Lower Limb',
  'Ex RMJ',
  'Ex Pushup',
  'Ex Situp'
];
List<String> soc = [
  'Ex Upper Limb',
  'LD',
  'Ex Lower Limb',
  'Ex RMJ',
  'Ex Uniform',
  'Ex Boots',
  'Ex FLEGS'
];
List MetabolicCircuit = [
  'Ex RMJ',
  'Ex Lower Limb',
  'LD',
];
List CombatCircuit = [
  'Ex Uniform',
  'Ex Boots',
  'Ex RMJ',
  'Ex Heavy Loads',
  'Ex Lower Limb',
  'Ex FLEGs',
  'LD',
];
List RouteMarch = [
  'Ex RMJ',
  'Ex Heavy Loads',
  'Ex Lower Limbs',
  'LD',
  'Ex Uniform',
  'Ex Boots',
  'Ex FLEGs',
];
int i = 0;
List<String> non_participants = [];
Map<String, String> soldierReason = {};

void autoFilter(String selectedConductType) {
  non_participants = [];
  switch (selectedConductType) {
    case 'Run':
      for (var status in statusList) {
        if (status['statusType'] == 'Excuse') {
          if (Run.contains(status['statusName'])) {
            non_participants.add(status['Name']);
            //soldierReason.addAll({status['Name']: status['statusName']});
          }
        } else if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
      break;
    case 'Route March':
      for (var status in statusList) {
        if (status['statusType'] == 'Excuse') {
          if (RouteMarch.contains(status['statusName'])) {
            non_participants.add(status['Name']);
            //soldierReason.addAll({status['Name']: status['statusName']});
          }
        } else if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
      break;
    case 'IPPT':
      for (var status in statusList) {
        if (status['statusType'] == 'Excuse') {
          if (Ippt.contains(status['statusName'])) {
            non_participants.add(status['Name']);
            //soldierReason.addAll({status['Name']: status['statusName']});
          }
        } else if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
      break;
    case 'Outfield':
      for (var status in statusList) {
        if (status['statusType'] == 'Excuse') {
          if (Outfield.contains(status['statusName'])) {
            non_participants.add(status['Name']);
            //soldierReason.addAll({status['Name']: status['statusName']});
          }
        } else if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
      break;
    case 'Metabolic Circuit':
      for (var status in statusList) {
        if (status['statusType'] == 'Excuse') {
          if (MetabolicCircuit.contains(status['statusName'])) {
            non_participants.add(status['Name']);
            //soldierReason.addAll({status['Name']: status['statusName']});
          }
        } else if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
      break;
    case 'Strength & Power':
      for (var status in statusList) {
        if (status['statusType'] == 'Excuse') {
          if (S_P.contains(status['statusName'])) {
            non_participants.add(status['Name']);
            //soldierReason.addAll({status['Name']: status['statusName']});
          }
        } else if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
      break;
    case 'Combat Circuit':
      for (var status in statusList) {
        if (status['statusType'] == 'Excuse') {
          if (CombatCircuit.contains(status['statusName'])) {
            non_participants.add(status['Name']);
            //soldierReason.addAll({status['Name']: status['statusName']});
          }
        } else if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
      break;
    case 'Live Firing':
      for (var status in statusList) {
        if (status['statusType'] == 'Excuse') {
          if (Atp.contains(status['statusName']) ||
              Imt.contains(status['statusName'])) {
            non_participants.add(status['Name']);
            //soldierReason.addAll({status['Name']: status['statusName']});
          }
        } else if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
      break;
    case 'SOC/VOC':
      for (var status in statusList) {
        if (status['statusType'] == 'Excuse') {
          if (soc.contains(status['statusName'])) {
            non_participants.add(status['Name']);
            //soldierReason.addAll({status['Name']: status['statusName']});
          }
        } else if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
      break;
    default:
      for (var status in statusList) {
        if (status['statusType'] == 'Leave') {
          non_participants.add(status['Name']);
          //soldierReason.addAll({status['Name']: status['statusName']});
        }
      }
  }
  //documentIDs.removeWhere((element) => non_participants.contains(element));
}

void main() {
  group("autoFilter tests", () {
    test(
        'test that correct non_participants are highlighted when selectedConduct is Run',
        () {
      autoFilter('Run');
      expect(non_participants.length, equals(2));
    });
    test(
        'test that correct non_participants are highlighted when selectedConduct is Route March',
        () {
      autoFilter('Route March');
      expect(non_participants.length, equals(5));
    });
    test(
        'test that correct non_participants are highlighted when selectedConduct is IPPT',
        () {
      autoFilter('IPPT');
      expect(non_participants.length, equals(2));
    });
    test(
        'test that correct non_participants are highlighted when selectedConduct is Outfield',
        () {
      autoFilter('Outfield');
      expect(non_participants.length, equals(7));
    });
    test(
        'test that correct non_participants are highlighted when selectedConduct is Metabolic Circuit',
        () {
      autoFilter('Metabolic Circuit');
      expect(non_participants.length, equals(2));
    });
    test(
        'test that correct non_participants are highlighted when selectedConduct is Strength & Power',
        () {
      autoFilter('Strength & Power');
      expect(non_participants.length, equals(2));
    });
    test(
        'test that correct non_participants are highlighted when selectedConduct is Combat Circuit',
        () {
      autoFilter('Combat Circuit');
      expect(non_participants.length, equals(5));
    });

    test(
        'test that correct non_participants are highlighted when selectedConduct is Live Firing',
        () {
      autoFilter('Live Firing');
      expect(non_participants.length, equals(5));
    });
    test(
        'test that correct non_participants are highlighted when selectedConduct is SOC/VOC',
        () {
      autoFilter('SOC/VOC');
      expect(non_participants.length, equals(5));
    });
    test(
        'test that correct non_participants are highlighted when selectedConduct is empty or null',
        () {
      autoFilter('');
      expect(non_participants.length, equals(1));
    });
  });
}
