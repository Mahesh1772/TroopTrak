import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadUserName extends StatelessWidget {
  const ReadUserName({required this.docIDs, super.key});

  final String docIDs;

  @override
  Widget build(BuildContext context) {
    // get the collection
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    /*return FutureBuilder<DocumentSnapshot>(
      future: users.doc(docIDs).get(),
      builder: (context, snapshot) {
        //IF connection with the firebase is ensured, then we execute
        if (snapshot.connectionState == ConnectionState.done) {

          //We are trying to map the key and values pairs
          //to a variable called "data" of Type Map
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Text(
            docIDs 
          );
          //return data;
        }
        return const Text('Loading......');

        //Returning the value for key called name
      },
    );*/
    return StreamBuilder(
      stream: users.doc(docIDs).snapshots(),
      builder: (context, snapshot) {
        //IF connection with the firebase is ensured, then we execute
        if (snapshot.hasData) {

          //We are trying to map the key and values pairs
          //to a variable called "data" of Type Map
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Text(
            docIDs
          );
          //return data;
        }
        return const Text('Loading......');

        //Returning the value for key called name
      },
    );
  }
}
