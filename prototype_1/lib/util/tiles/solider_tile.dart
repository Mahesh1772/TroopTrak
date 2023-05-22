import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/screens/soldier_detailed_screen.dart';

class SoldierTile extends StatelessWidget {
  final String soldierName;
  final String soldierRank;
  final String soldierAttendance;
  final String soldierIcon;
  final Color tileColor;
  final String company;
  final String platoon;
  final String section;
  final String soldierAppointment;
  final String dateOfBirth;
  final String rationType;
  final String bloodType;
  final String enlistmentDate;
  final String ordDate;

  const SoldierTile({
    super.key,
    required this.soldierIcon,
    required this.soldierName,
    required this.soldierRank,
    required this.tileColor,
    required this.soldierAttendance,
    required this.company,
    required this.platoon,
    required this.section,
    required this.soldierAppointment,
    required this.dateOfBirth,
    required this.rationType,
    required this.bloodType,
    required this.enlistmentDate,
    required this.ordDate,
  });

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
                      soldierAttendance: soldierAttendance,
                      company: company,
                      platoon: platoon,
                      section: section,
                      dateOfBirth: dateOfBirth,
                      enlistmentDate: enlistmentDate,
                      ordDate: ordDate,
                      soldierAppointment: soldierAppointment,
                      rationType: rationType,
                      bloodType: bloodType,
                      tileColor: tileColor,
                    )),
          );
        },
        child: Container(
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(
                blurRadius: 2.0,
                spreadRadius: 2.0,
                offset: Offset(10, 10),
                color: Colors.black54)
          ], color: tileColor, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              //rank insignia
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12)),
                    ),
                    child: Image.asset(
                      soldierRank,
                      width: 30,
                    ),
                  ),
                ],
              ),

              //soldier icon
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                child: Image.asset(
                  soldierIcon,
                  width: 90,
                ),
              ),

              //name

              Center(
                  child: Text(
                soldierName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),

              StyledText(
                soldierAttendance,
                14,
                fontWeight: FontWeight.w500,
              )
            ],
          ),
        ),
      ),
    );
  }
}
