import 'package:flutter/material.dart';
import 'package:prototype_1/text_style.dart';
import 'package:prototype_1/util/solider_tile.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  List unitSoldiers = [
    //[ soldierName, soldierRank, tileColour, soldierAttendance, soldierIcon]

    [
      "Sivagnanam Maheshwaran",
      "lib/assets/army-ranks/3sg.png",
      Colors.blue,
      "IN CAMP",
      "lib/assets/army-ranks/soldier.png"
    ],
    [
      "Aakash Ramaswamy",
      "lib/assets/army-ranks/3sg.png",
      Colors.lightBlue,
      "NOT IN CAMP",
      "lib/assets/army-ranks/soldier.png"
    ],
    [
      "Nikhil Babu",
      "lib/assets/army-ranks/cfc.png",
      Colors.blueGrey,
      "IN CAMP",
      "lib/assets/army-ranks/men.png"
    ],
    [
      "John Doe",
      "lib/assets/army-ranks/lcp.png",
      Colors.blueAccent,
      "NOT IN CAMP",
      "lib/assets/army-ranks/men.png"
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: StyledText('Dashboard', 20),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'lib/assets/user.png',
                    width: 50,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: StyledText('Welcome,\nAakash! 👋', 32),
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
