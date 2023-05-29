import 'package:flutter/material.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/screens/soldier_detailed_screen.dart';
import 'dart:math' as math;

class DashboardSoldierTile extends StatelessWidget {
  final String soldierName;
  final String soldierRank;
  final String company;
  final String platoon;
  final String section;
  final String soldierAppointment;
  final String dateOfBirth;
  final String rationType;
  final String bloodType;
  final String enlistmentDate;
  final String ordDate;

  const DashboardSoldierTile(
      {super.key,
      required this.soldierName,
      required this.soldierRank,
      required this.company,
      required this.platoon,
      required this.section,
      required this.soldierAppointment,
      required this.dateOfBirth,
      required this.rationType,
      required this.bloodType,
      required this.enlistmentDate,
      required this.ordDate});

  @override
  Widget build(BuildContext context) {
    List colors = [
      Colors.brown.shade800,
      Colors.indigo.shade800,
      Colors.indigo.shade400,
      Colors.teal.shade800,
      Colors.teal.shade400,
    ];

    int index = math.Random().nextInt(4);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SoldierDetailedScreen(
                      soldierName: soldierName,
                      soldierRank: soldierRank,
                      company: company,
                      platoon: platoon,
                      section: section,
                      dateOfBirth: dateOfBirth,
                      enlistmentDate: enlistmentDate,
                      ordDate: ordDate,
                      soldierAppointment: soldierAppointment,
                      rationType: rationType,
                      bloodType: bloodType,
                    )),
          );
        },
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(
                blurRadius: 2.0,
                spreadRadius: 2.0,
                offset: Offset(10, 10),
                color: Colors.black54)
          ], color: colors[index], borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //soldier icon
                  Image.asset(
                    "lib/assets/army-ranks/soldier.png",
                    width: 60,
                  ),

                  //rank insignia
                  Image.asset(
                    soldierRank,
                    width: 30,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              StyledText(soldierName, 20, fontWeight: FontWeight.bold)
            ],
          ),
        ),
      ),
    );
  }
}
