import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadUserStatus extends StatelessWidget {
  const ReadUserStatus({
    required this.docIDs,
    required this.statusID,
    super.key,
  });

  final String docIDs;
  final String statusID;

  @override
  Widget build(BuildContext context) {
    // get the collection

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(docIDs)
          .collection('Statuses')
          .doc(statusID)
          .get(),
      builder: (context, snapshot) {
        //IF connection with the firebase is ensured, then we execute
        if (snapshot.connectionState == ConnectionState.done) {
          //We are trying to map the key and values pairs
          //to a variable called "data" of Type Map
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Text('Status ${data['Status']}');
          //return data;
        }
        return const Text('Loading......');

        //Returning the value for key called name
      },
    );
  }
}
