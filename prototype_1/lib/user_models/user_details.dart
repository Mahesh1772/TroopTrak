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

  Stream<QuerySnapshot> get data {
    soldiers = FirebaseFirestore.instance.collection('Users').snapshots();
    return soldiers;
  }

  Stream<QuerySnapshot> get conducts_data {
    conducts = FirebaseFirestore.instance.collection('Conducts').snapshots();
    return conducts;
  }

}
