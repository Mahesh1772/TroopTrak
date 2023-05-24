import 'package:flutter/material.dart';
import 'package:prototype_1/screens/update_soldier_details_screen.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import '../../util/text_styles/soldier_detailed_screen_info_template.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var fname = FirebaseAuth.instance.currentUser!.displayName.toString();
var id = FirebaseAuth.instance.currentUser!;
List profile = [
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
];
class BasicInfoTab extends StatefulWidget {
  const BasicInfoTab(
      {super.key,
      required this.dateOfBirth,
      required this.rationType,
      required this.bloodType,
      required this.enlistmentDate,
      required this.ordDate});

  final String dateOfBirth;
  final String rationType;
  final String bloodType;
  final String enlistmentDate;
  final String ordDate;

  @override
  State<BasicInfoTab> createState() => _BasicInfoTabState();
}

class _BasicInfoTabState extends State<BasicInfoTab> {

  Future deleteUserAccount() async{
  deleteCurrentUser();
  id.delete();
  Navigator.pop(context);
}

Future deleteCurrentUser() async {
  FirebaseFirestore.instance.collection("Users").doc(fname).delete();
}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Column(
        children: [
          SoldierDetailedInfoTemplate(
            title: "Date Of Birth",
            content: profile[9].toUpperCase(),
            icon: Icons.cake_rounded,
          ),
          SoldierDetailedInfoTemplate(
            title: "Ration Type:",
            content: profile[10].toUpperCase(),
            icon: Icons.food_bank_rounded,
          ),
          SoldierDetailedInfoTemplate(
            title: "Blood Type:",
            content: profile[11].toUpperCase(),
            icon: Icons.bloodtype_rounded,
          ),
          SoldierDetailedInfoTemplate(
            title: "Enlistment Date:",
            content: profile[12].toUpperCase(),
            icon: Icons.date_range_rounded,
          ),
          SoldierDetailedInfoTemplate(
            title: "ORD:",
            content: profile[13].toUpperCase(),
            icon: Icons.military_tech_rounded,
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdateSoldierDetailsPage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40.0, vertical: 16.0),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 72, 30, 229),
                        Color.fromARGB(255, 130, 60, 229),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50.0)),
                child: const StyledText("EDIT SOLDIER DETAILS", 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: TextButton(
              onPressed: deleteUserAccount,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 16.0),
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    gradient: const LinearGradient(
                      colors: [Colors.red, Color.fromARGB(255, 237, 131, 124)],
                    ),
                    borderRadius: BorderRadius.circular(50.0)),
                child: const StyledText("DELETE SOLDIER DETAILS", 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
