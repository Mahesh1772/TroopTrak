import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserData extends ChangeNotifier {
  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

  Stream<QuerySnapshot> status = Stream.empty();
  Stream<DocumentSnapshot<Map<String, dynamic>>> userData =
      const Stream.empty();

  // DocumentReference<Map<String, dynamic>>(Users/8bu245T440NIuQnJhm81)
  // This is the sample output, to get IDs we just do .id
  List<Map<String, dynamic>> userDetails = [];

  Future futuremethod() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((querySnapshot) {
      for (var result in querySnapshot.docs) {
        Map<String, dynamic> data = result.data();
        userDetails.add(data);
      }
    });
  }

  Stream<QuerySnapshot> attendance_data(String docID) {
    status = FirebaseFirestore.instance
        .collection('Users')
        .doc(docID)
        .collection('Attendance')
        .snapshots();
    return status;
  }

  Stream<QuerySnapshot> status_data(String docID) {
    status = FirebaseFirestore.instance
        .collection('Users')
        .doc(docID)
        .collection('Statuses')
        .snapshots();
    return status;
  }

  int i = 0;
  List<Map<String, dynamic>> attendance_list = [];
  Future inCamp() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(snapshot.id)
            .collection("Attendance")
            .get()
            .then((querySnapshot) {
          //var lastData = querySnapshot.docs.last.data();
          fullList.addAll(
              {snapshot.id: querySnapshot.docs.last.data()['isInsideCamp']});
        });
      }
    });
    //return attendance_list;
  }

  List<Map<String, dynamic>> newList = [];
  Map<String, dynamic> fullList = {};

  List<String> non_participants = [];
  List<Map<String, dynamic>> statusList = [];
  List<String> guardDuty = ['Ex Uniform', 'Ex Boots'];
  Future autoFilter() async {
    if (statusList.isNotEmpty) {
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
  }

  Future<bool> getUserStatus(String ID) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(ID)
        .collection("Statuses")
        .where('statusType', isEqualTo: 'Excuse')
        .where('statusName', whereIn: ['Ex Boots', 'Ex Uniform'])
        .get()
        .then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            Map<String, dynamic> data = result.data();
            DateTime end = DateFormat("d MMM yyyy").parse(data['endDate']);
            if (DateTime(end.year, end.month, end.day + 1)
                .isAfter(DateTime.now())) {
              return true;
            }
          }
        });
    return false;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userData_data(String docID) {
    userData =
        FirebaseFirestore.instance.collection('Users').doc(docID).snapshots();
    return userData;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> menData_data(String docID) {
    userData =
        FirebaseFirestore.instance.collection('Men').doc(docID).snapshots();
    return userData;
  }

  Future name() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        Map<String, dynamic> data = snapshot.data();
        documentIDs.add(data['name']);
      }
    });
    //return attendance_list;
  }

  List<Map<String, dynamic>> getUserData() {
    futuremethod();
    return userDetails;
  }
}
