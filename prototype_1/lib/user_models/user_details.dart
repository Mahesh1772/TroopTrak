//import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData extends ChangeNotifier {
  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

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
        if (!userDetails.contains(data)) {
          userDetails.add(data);
        }
      }
    });
  }

  List<Map<String, dynamic>> getUserData() {
    List<Map<String, dynamic>> newSet = [];
    futuremethod();
    for (var user in userDetails) {
      if (newSet.isNotEmpty && !newSet.contains(user)) {
        newSet.add(user);
      }
      else {
        newSet = userDetails;
      }
    }
    //notifyListeners();
    return newSet;
  }
}
