// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:prototype_1/add_new_soldier_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype_1/constants.dart';
import 'package:prototype_1/text_style.dart';
import 'package:prototype_1/util/solider_tile.dart';

class NominalRollNewScreen extends StatelessWidget {
  NominalRollNewScreen({super.key});

  List unitSoldiers = [
    //[ soldierName, soldierRank, tileColour, soldierAttendance, soldierIcon, rationType, dateOfBirth]

    [
      "Wei John Koh",
      "lib/assets/army-ranks/3sg.png",
      Colors.brown.shade800,
      "IN CAMP",
      "lib/assets/army-ranks/soldier.png"
    ],
    [
      "Sivagnanam Maheshwaran",
      "lib/assets/army-ranks/3sg.png",
      Colors.indigo.shade800,
      "IN CAMP",
      "lib/assets/army-ranks/soldier.png"
    ],
    [
      "Aakash Ramaswamy",
      "lib/assets/army-ranks/3sg.png",
      Colors.indigo.shade400,
      "NOT IN CAMP",
      "lib/assets/army-ranks/soldier.png"
    ],
    [
      "Nikhil Babu",
      "lib/assets/army-ranks/cfc.png",
      Colors.teal.shade800,
      "IN CAMP",
      "lib/assets/army-ranks/men.png"
    ],
    [
      "John Doe",
      "lib/assets/army-ranks/lcp.png",
      Colors.teal.shade400,
      "NOT IN CAMP",
      "lib/assets/army-ranks/men.png"
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
                builder: (context) => const AddNewSoldierPage(),
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
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'lib/assets/user.png',
                    width: 50,
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
