import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

List<String> documentIDs = [];
List<Map<String, dynamic>> statusList = [];
List<String> Outfield = [
  'Ex Sunlight',
  'Ex grass',
  'Ex Outfield',
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

class ParticipantAutoSelect {
  ParticipantAutoSelect({
    required this.conductType,
    //required this.documentIDs,
  });

  String? conductType;

  Future getUserBooks() async {
    FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(snapshot.id)
            .collection("Statuses")
            .get()
            .then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            Map<String, dynamic> data = result.data();
            if (DateFormat("d MMM yyyy")
                .parse(data['endDate'])
                .isAfter(DateTime.now())) {
              statusList.add(data);
              statusList[i].addEntries({'Name': snapshot.id}.entries);
              i++;
            }
          }
        });
      }
    });
  }

  Future getDocIDs() async {
    FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((value) => value.docs.forEach((element) {
              documentIDs.add(element['name']);
            }));
  }

  void isOnLeave() {
    for (var status in statusList) {
      if (status['statusType'] == 'Leave') {
        non_participants.add(status['Name']);
      }
    }
  }

  void isFitForOutField() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (Outfield.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  void isFitForOutRun() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (Run.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  void isFitForOutImt() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (Imt.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  void isFitForOutsoc() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (soc.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  void isFitForOutIppt() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (Ippt.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  void isFitForOutAtp() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (Atp.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  void isFitForOutS_P() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (S_P.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  void isFitForOutCC() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (CombatCircuit.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  void isFitForOutRouteMarch() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (RouteMarch.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  void isFitForOutMC() {
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (MetabolicCircuit.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      }
    }
  }

  List<String> auto_filter1() {
    //documentIDs = [];
    getDocIDs();
    getUserBooks();
    switch (conductType) {
      case 'Run':
        isFitForOutRun();
        break;
      case 'Route March':
        isFitForOutRouteMarch();
        break;
      case 'IPPT':
        isFitForOutIppt();
        break;
      case 'Outfield':
        isFitForOutField();
        break;
      case 'Metabolic Circuit':
        isFitForOutMC();
        break;
      case 'Strength & Power':
        isFitForOutS_P();
        break;
      case 'Combat Circuit':
        isFitForOutCC();
        break;
      case 'Live Firing':
        isFitForOutAtp();
        isFitForOutImt();
        break;
      case 'SOC/VOC':
        isFitForOutsoc();
        break;
      default:
        null;
    }
    isOnLeave();
    documentIDs.removeWhere((element) => non_participants.contains(element));
    return documentIDs;
  }

  void auto_filter() {
    //documentIDs = [];
    getDocIDs();
    getUserBooks();
    switch (conductType) {
      case 'Run':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (Run.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Route March':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (RouteMarch.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'IPPT':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (Ippt.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Outfield':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (Outfield.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Metabolic Circuit':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (MetabolicCircuit.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Strength & Power':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (S_P.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Combat Circuit':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (CombatCircuit.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'Live Firing':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (Atp.contains(status['statusName']) ||
                Imt.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      case 'SOC/VOC':
        for (var status in statusList) {
          if (status['statusType'] == 'Excuse') {
            if (soc.contains(status['statusName'])) {
              non_participants.add(status['Name']);
            }
          } else if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
        break;
      default:
        for (var status in statusList) {
          if (status['statusType'] == 'Leave') {
            non_participants.add(status['Name']);
          }
        }
    }
    documentIDs.removeWhere((element) => non_participants.contains(element));
    //return documentIDs;
  }
}
