import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_1/screens/home/edit_user.dart';
import 'package:firebase_project_1/screens/home/read_custom_user_id.dart';
import 'package:firebase_project_1/screens/home/add_new_soldier_screen.dart';
import 'package:firebase_project_1/screens/home/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_project_1/screens/home/read_user_rank.dart';

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

  // New list to hold the new updated list on search
  List<String> updated_documentIDs = [];

  // Test data to store rank
  String rankOfUser = '';

  // DocumentReference<Map<String, dynamic>>(Users/8bu245T440NIuQnJhm81)
  // This is the sample output, to get IDs we just do .id

  Future getDocIDs() async {
    await FirebaseFirestore.instance
        .collection('Users')
        //.orderBy('rank', descending: false)
        .get()
        .then((snapshot) => {
              snapshot.docs.forEach((document) {
                print(document.reference);
                documentIDs.add(document.reference.id);
              })
            });
    documentIDs.sort();
    updated_documentIDs = documentIDs;
    setState(() {});
  }

  @override
  void initState() {
    getDocIDs();
    super.initState();
    documentIDs = [];
  }

  void reset() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  void updateList(String value) {
    // This will be used to make the new list with searched word
    setState(() {
      updated_documentIDs = documentIDs
          .where(
              (element) => element.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future createUserModel(docIDs) async {
    //CollectionReference users = FirebaseFirestore.instance.collection('Users');
    //await users.doc(docIDs).get();
    final DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(docIDs).get();
    Map<String, dynamic> values =
        documentSnapshot.data() as Map<String, dynamic>;
    return values;
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                onChanged: (value) => updateList(value),
                decoration: InputDecoration(
                  hintText: 'Search Name',
                  prefixIcon: const Icon(Icons.search_sharp),
                  prefixIconColor: Colors.indigo.shade900,
                  fillColor: Colors.amber,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            // This has a FutureBuilder as it needs
            // to wait for executiion of getDocIDs function to finish execution
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: updated_documentIDs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditUserDetails(),
                            ),
                          );
                        },
                        child: ListTile(
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              width: 2,
                              color: Colors.indigo,
                            ),
                          ),
                          title:
                              ReadUserName(docIDs: updated_documentIDs[index]),
                          subtitle:
                              ReadUserRank(docIDs: updated_documentIDs[index]),
                          tileColor: Colors.indigo.shade300,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: reset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text('Refresh'),
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
