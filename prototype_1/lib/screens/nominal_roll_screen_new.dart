// ignore_for_file: must_be_immutable

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

  void reset() {
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

  List unitSoldiers = [
    //[ soldierName, soldierRank, tileColour, soldierAttendance, soldierIcon, soldierAppointment, companyName,
    //platoonName, sectionNumber, dateOfBirth, rationType, bloodType, enlistmentDate, ordDate]

    [
      "Wei John Koh",
      "lib/assets/army-ranks/3sg.png",
      Colors.brown.shade800,
      "IN CAMP",
      "lib/assets/army-ranks/soldier.png",
      "section commander",
      "Alpha",
      "4",
      "3",
      "04 May 2001",
      "VC",
      "AB+",
      "11 Aug 2020",
      "10 Aug 2022",
    ],
    [
      "Sivagnanam Maheshwaran",
      "lib/assets/army-ranks/3sg.png",
      Colors.indigo.shade800,
      "IN CAMP",
      "lib/assets/army-ranks/soldier.png",
      "LOGISTICS SPECIALIST",
      "Bravo",
      "1",
      "2",
      "05 Apr 2001",
      "VI",
      "AB+",
      "11 Aug 2019",
      "10 Aug 2021",
    ],
    [
      "Aakash Ramaswamy",
      "lib/assets/army-ranks/3sg.png",
      Colors.indigo.shade400,
      "NOT IN CAMP",
      "lib/assets/army-ranks/soldier.png",
      "MARKSMAN TEAM COMMANDER",
      "Charlie",
      "HQ",
      "MM",
      "02 Apr 2002",
      "VI",
      "O+",
      "11 Aug 2020",
      "10 Aug 2022",
    ],
    [
      "Nikhil Babu",
      "lib/assets/army-ranks/cfc.png",
      Colors.teal.shade800,
      "IN CAMP",
      "lib/assets/army-ranks/men.png",
      "Section 2IC",
      "Bn HQ",
      "2",
      "4",
      "03 Sept 2000",
      "M",
      "B+",
      "10 Aug 2020",
      "09 Aug 2022",
    ],
    [
      "John Doe",
      "lib/assets/army-ranks/lcp.png",
      Colors.teal.shade400,
      "NOT IN CAMP",
      "lib/assets/army-ranks/men.png",
      "1st MATADOR GUNNER",
      "Support",
      "3",
      "3",
      "04 Jul 2003",
      "NM",
      "A+",
      "11 Jul 2021",
      "10 Jul 2023",
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    selectedBloodType: "Select your blood type..."),
              ),
            );
          },
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.add)),
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SafeArea(
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
                    20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 90.0),
                  child: InkWell(
                    onTap: () {
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
                                  soldierName: unitSoldiers[1][0],
                                  soldierRank: unitSoldiers[1][1],
                                  tileColor: unitSoldiers[1][2],
                                  soldierAttendance: unitSoldiers[1][3],
                                  soldierIcon: unitSoldiers[1][4],
                                  soldierAppointment: unitSoldiers[1][5],
                                  company: unitSoldiers[1][6],
                                  platoon: unitSoldiers[1][7],
                                  section: unitSoldiers[1][8],
                                  dateOfBirth: unitSoldiers[1][9],
                                  rationType: unitSoldiers[1][10],
                                  bloodType: unitSoldiers[1][11],
                                  enlistmentDate: unitSoldiers[1][12],
                                  ordDate: unitSoldiers[1][13],
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
                32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: GridView.builder(
                itemCount: unitSoldiers.length,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1 / 1.5),
                itemBuilder: (context, index) {
                  return SoldierTile(
                    soldierName: unitSoldiers[index][0],
                    soldierRank: unitSoldiers[index][1],
                    tileColor: unitSoldiers[index][2],
                    soldierAttendance: unitSoldiers[index][3],
                    soldierIcon: unitSoldiers[index][4],
                    soldierAppointment: unitSoldiers[index][5],
                    company: unitSoldiers[index][6],
                    platoon: unitSoldiers[index][7],
                    section: unitSoldiers[index][8],
                    dateOfBirth: unitSoldiers[index][9],
                    rationType: unitSoldiers[index][10],
                    bloodType: unitSoldiers[index][11],
                    enlistmentDate: unitSoldiers[index][12],
                    ordDate: unitSoldiers[index][13],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
