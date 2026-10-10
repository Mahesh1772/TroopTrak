import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'builders.dart';

class SeededSoldier {
  const SeededSoldier(
    this.doc, {
    this.statuses = const [],
    this.attendance = const {},
  });

  final Map<String, dynamic> doc;
  final List<Map<String, dynamic>> statuses;
  final Map<String, Map<String, dynamic>> attendance;
}

Future<FakeFirebaseFirestore> seedFirestore({
  List<SeededSoldier> soldiers = const [],
  List<Map<String, dynamic>> conducts = const [],
  List<Map<String, dynamic>> duties = const [],
  Map<String, Map<String, dynamic>> men = const {},
}) async {
  final db = FakeFirebaseFirestore();
  for (final soldier in soldiers) {
    final ref = db.collection('Users').doc(soldier.doc['name'] as String);
    await ref.set(soldier.doc);
    for (final status in soldier.statuses) {
      await ref.collection('Statuses').add(status);
    }
    for (final entry in soldier.attendance.entries) {
      await ref.collection('Attendance').doc(entry.key).set(entry.value);
    }
  }
  for (final conduct in conducts) {
    await db.collection('Conducts').add(conduct);
  }
  for (final duty in duties) {
    await db.collection('Duties').add(duty);
  }
  for (final entry in men.entries) {
    await db.collection('Men').doc(entry.key).set(entry.value);
  }
  return db;
}

Future<FakeFirebaseFirestore> seedSampleUnit() => seedFirestore(
      soldiers: [
        SeededSoldier(
          soldierDoc(),
          statuses: [statusDoc()],
          attendance: {'2023-07-05 08:00:00': attendanceDoc()},
        ),
        SeededSoldier(soldierDoc(name: 'Lee Wei', rank: '2LT')),
      ],
      conducts: [conductDoc()],
      duties: [dutyDoc()],
      men: {'uid-1': menDoc(qrId: 'qr-123')},
    );
