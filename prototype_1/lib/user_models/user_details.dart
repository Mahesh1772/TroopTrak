//import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}