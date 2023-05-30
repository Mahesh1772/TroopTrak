// ignore_for_file: must_be_immutable
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prototype_1/screens/add_new_soldier_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype_1/screens/user_profile_screen.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/util/tiles/solider_tile.dart';
import 'package:intl/intl.dart';

class NominalRollNewScreen extends StatefulWidget {
  const NominalRollNewScreen({super.key});

  @override
  State<NominalRollNewScreen> createState() => _NominalRollNewScreenState();
}

class _NominalRollNewScreenState extends State<NominalRollNewScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

  // New list to hold the new updated list on search
  List<String> updatedDocumentIDs = [];

  // List to store all user data
  List<Map> userDetails = [];

  Future getDocIDs() async {
    await FirebaseFirestore.instance
        .collection('Users')
        //.orderBy('rank', descending: false)
        .get()
        .then((snapshot) => {
              snapshot.docs.forEach((document) {
                documentIDs.add(document.reference.id);
                userDetails.add(document.data());
              })
            });
    //documentIDs.sort();
    updatedDocumentIDs = documentIDs;
    setState(() {});
  }

  @override
  void initState() {
    getDocIDs();
    super.initState();
    documentIDs = [];
  }

  Future<void> reset() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => super.widget));
  }

  void updateList(String value) {
    // This will be used to make the new list with searched word
    setState(() {
      updatedDocumentIDs = documentIDs
          .where(
              (element) => element.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewSoldierPage(
                  name: TextEditingController(),
                  company: TextEditingController(),
                  platoon: TextEditingController(),
                  section: TextEditingController(),
                  appointment: TextEditingController(),
                  dob: DateFormat('d MMM yyyy').format(DateTime.now()),
                  ord: DateFormat('d MMM yyyy').format(DateTime.now()),
                  enlistment: DateFormat('d MMM yyyy').format(DateTime.now()),
                  selectedItem: "Select your ration type...",
                  selectedRank: "Select your rank...",
                  selectedBloodType: "Select your blood type...",
                ),
              ),
            );
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add),
        ),
        backgroundColor: const Color.fromARGB(255, 21, 25, 34),
        body: LiquidPullToRefresh(
          onRefresh: reset,
          color: Colors.deepPurple,
          height: 250,
          animSpeedFactor: 5,
          showChildOpacityTransition: false,
          springAnimationDurationInMilliseconds: 250,
          borderWidth: 7,
          backgroundColor: Colors.deepPurple.shade200,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: StyledText(
                        'Nominal Roll',
                        30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: InkWell(
                        onTap: () {
                          //display();
                          FirebaseAuth.instance.signOut();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black54,
                                  offset: Offset(10.0, 10.0),
                                  blurRadius: 2.0,
                                  spreadRadius: 2.0),
                            ],
                            color: Colors.deepPurple.shade400,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(defaultPadding),
                            child: Icon(
                              Icons.exit_to_app_rounded,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserProfileScreen(
                                      soldierName:
                                          documentIDs[0], //unitSoldiers[
                                      soldierRank:
                                          "lib/assets/army-ranks/3sg.png", //
                                      soldierAppointment: userDetails[0]
                                          ['appointment'],
                                      company: userDetails[0]['company'],
                                      platoon: userDetails[0]['platoon'],
                                      section: userDetails[0]['section'],
                                      dateOfBirth: userDetails[0]['dob'],
                                      rationType: userDetails[0]['rationType'],
                                      bloodType: userDetails[0]['bloodgroup'],
                                      enlistmentDate: userDetails[0]
                                          ['enlistment'],
                                      ordDate: userDetails[0]['ord'],
                                    )));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'lib/assets/user.png',
                          width: 50,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: StyledText(
                    'Our Family of Soldiers:',
                    20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
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
                Expanded(
                  child: GridView.builder(
                    itemCount: documentIDs.length,
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, childAspectRatio: 1 / 1.5),
                    itemBuilder: (context, index) {
                      return SoldierTile(
                        soldierName:
                            documentIDs[index], //unitSoldiers[index][0],
                        soldierRank:
                            "lib/assets/army-ranks/3sg.png", //unitSoldiers[index][1],
                        soldierAppointment: userDetails[index]['appointment'],
                        company: userDetails[index]['company'],
                        platoon: userDetails[index]['platoon'],
                        section: userDetails[index]['section'],
                        dateOfBirth: userDetails[index]['dob'],
                        rationType: userDetails[index]['rationType'],
                        bloodType: userDetails[index]['bloodgroup'],
                        enlistmentDate: userDetails[index]['enlistment'],
                        ordDate: userDetails[index]['ord'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
