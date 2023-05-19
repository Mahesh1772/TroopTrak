import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/text_style.dart';
import 'package:prototype_1/util/soldier_detailed_screen.dart';

class DashboardSoldierTile extends StatelessWidget {
  final String soldierName;
  final String soldierRank;
  final String soldierAttendance;
  final String soldierIcon;
  final Color tileColor;

  const DashboardSoldierTile(
      {super.key,
      required this.soldierIcon,
      required this.soldierName,
      required this.soldierRank,
      required this.tileColor,
      required this.soldierAttendance});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SoldierDetailedScreen(
                    soldierIcon: soldierIcon,
                    soldierName: soldierName,
                    soldierRank: soldierRank,
                    soldierAttendance: soldierAttendance)),
          );
        },
        child: Container(
          width: 200,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(
                blurRadius: 2.0,
                spreadRadius: 2.0,
                offset: Offset(10, 10),
                color: Colors.black54)
          ], color: tileColor, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //soldier icon
                  Image.asset(
                    soldierIcon,
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
