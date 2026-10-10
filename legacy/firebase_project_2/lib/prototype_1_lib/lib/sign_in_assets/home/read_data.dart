import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadData extends StatelessWidget {
  const ReadData({required this.docIDs, super.key});

  final String docIDs;

  @override
  Widget build(BuildContext context) {
    // get the collection
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(docIDs).get(),
      builder: (context, snapshot) {
        //IF connection with the firebase is ensured, then we execute
        if (snapshot.connectionState == ConnectionState.done) {
          //We are trying to map the key and values pairs
          //to a variable called "data" of Type Map
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          //Returning the value for key called name
          return Text('${data['name']}, Rank: ${data['rank']}');
        }
        return const Text('Loading......');
      },
    );
  }
}
