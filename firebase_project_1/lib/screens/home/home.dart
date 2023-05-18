import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_1/screens/home/read_data.dart';
import 'package:firebase_project_1/screens/home/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    await FirebaseFirestore.instance
        .collection('Users')
        .orderBy('rank', descending: false)
        .get()
        .then((snapshot) => {
              snapshot.docs.forEach((document) {
                print(document.reference);
                documentIDs.add(document.reference.id);
              })
            });

    setState(() {});
  }

  @override
  void initState() {
    getDocIDs();
    super.initState();
    documentIDs = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(
          child: Text(
            textAlign: TextAlign.center,
            'Display dashboard',
            style: TextStyle(
              fontSize: 30,
              color: Colors.tealAccent.shade400,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(
                Icons.logout_sharp,
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.deepPurple.shade200,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // This has a FutureBuilder as it needs
            // to wait for executiion of getDocIDs function to finish execution
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: documentIDs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            width: 2,
                            color: Colors.indigo,
                          ),
                        ),
                        title: ReadData(docIDs: documentIDs[index]),
                        tileColor: Colors.indigo.shade300,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UpdateProfile()));
        },
        backgroundColor: Colors.tealAccent,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
