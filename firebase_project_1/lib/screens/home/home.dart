import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_1/screens/home/read_data.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;

  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

  // DocumentReference<Map<String, dynamic>>(Users/8bu245T440NIuQnJhm81)
  // This is the sample output, to get IDs we just do .id
  Future getDocIDs() async {
    await FirebaseFirestore.instance.collection('Users').get().then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
              print(document.reference);
              documentIDs.add(document.reference.id);
            },
          ),
        );
  }

  @override
  void initState() {
    getDocIDs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade200,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Display dashboard',
              style: TextStyle(fontSize: 30, color: Colors.indigo.shade800),
            ),
            MaterialButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              color: Colors.deepPurpleAccent,
              child: const Text('Sign Out'),
            ),

            // This has a FutureBuilder as it needs
            // to wait for executiion of getDocIDs function to finish execution
            Expanded(child: FutureBuilder(
              builder: (context, index) {
                future:
                getDocIDs();
                return ListView.builder(
                  itemCount: documentIDs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: ReadData(docIDs: documentIDs[index]),
                    );
                  },
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
