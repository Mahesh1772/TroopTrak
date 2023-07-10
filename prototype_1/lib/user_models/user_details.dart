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
  Future<List<Map<String, dynamic>>> inCamp() async {
    FirebaseFirestore.instance
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
          for (var result in querySnapshot.docs) {
            Map<String, dynamic> data = result.data();
            attendance_list.add(data);
            attendance_list[i].addEntries({'Name': snapshot.id}.entries);
            i++;
          }
        });
      }
    });
    attendance_list.sort((m1, m2) {
      var r = DateFormat("E d MMM yyyy HH:mm:ss")
          .parse(m1["date&time"])
          .compareTo(
              DateFormat("E d MMM yyyy HH:mm:ss").parse(m2["date&time"]));
      if (r != 0) return r;
      return DateFormat("E d MMM yyyy HH:mm:ss")
          .parse(m1["date&time"])
          .compareTo(
              DateFormat("E d MMM yyyy HH:mm:ss").parse(m2["date&time"]));
    });
    attendance_list = attendance_list.reversed.toList();
    return attendance_list;
  }

  List<Map<String, dynamic>> newList = [];
  Map<String, dynamic> fullList = {};

  void last_attendance() async {
    newList = await inCamp();
    for (var i = 0; i < attendance_list.length - 1; i++) {
      String currentEntry = attendance_list[i]['Name'];
      String nextEntry = attendance_list[i + 1]['Name'];
      if (i == 0) {
        fullList.addAll({currentEntry : attendance_list[i]['isInsideCamp']});
      }

      if (currentEntry != nextEntry) {
        fullList.addAll({nextEntry : attendance_list[i]['isInsideCamp']});
      }
    }
  }
}
