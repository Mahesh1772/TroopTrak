//import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserData extends ChangeNotifier {
  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

  // DocumentReference<Map<String, dynamic>>(Users/8bu245T440NIuQnJhm81)
  // This is the sample output, to get IDs we just do .id
  List<Map<String, dynamic>> userDetails = [];

  Stream<QuerySnapshot> soldiers = Stream.empty();
  Stream<QuerySnapshot> conducts = Stream.empty();
  Stream<QuerySnapshot> duty = Stream.empty();
  Stream<QuerySnapshot> status = Stream.empty();
  Stream<DocumentSnapshot<Map<String, dynamic>>> userData = Stream.empty();

  Stream<QuerySnapshot> get data {
    soldiers = FirebaseFirestore.instance.collection('Users').snapshots();
    return soldiers;
  }

  Stream<QuerySnapshot> get conducts_data {
    conducts = FirebaseFirestore.instance.collection('Conducts').snapshots();
    return conducts;
  }

  Stream<QuerySnapshot> get duty_data {
    duty = FirebaseFirestore.instance.collection('Duties').snapshots();
    return duty;
  }

  Stream<QuerySnapshot> status_data(String docID) {
    status = FirebaseFirestore.instance
        .collection('Users')
        .doc(docID)
        .collection('Statuses')
        .snapshots();
    return status;
  }

  Stream<QuerySnapshot> attendance_data(String docID) {
    status = FirebaseFirestore.instance
        .collection('Users')
        .doc(docID)
        .collection('Attendance')
        .snapshots();
    return status;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userData_data(String docID) {
    userData =
        FirebaseFirestore.instance.collection('Users').doc(docID).snapshots();
    return userData;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> updateStatus_data(
      String docID, String statusID) {
    userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(docID)
        .collection('Statuses')
        .doc(statusID)
        .snapshots();
    return userData;
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
}
