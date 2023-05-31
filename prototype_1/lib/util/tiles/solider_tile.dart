import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/screens/soldier_detailed_screen.dart';
import 'dart:math' as math;

class SoldierTile extends StatelessWidget {
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

  const SoldierTile({
    super.key,
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
    required this.ordDate,
  });

  String soldierIconGenerator(String rank) {
    if (rank == 'lib/assets/army-ranks/rec.png' ||
        rank == 'lib/assets/army-ranks/pte.png' ||
        rank == 'lib/assets/army-ranks/lcp.png' ||
        rank == 'lib/assets/army-ranks/cpl.png' ||
        rank == 'lib/assets/army-ranks/cfc.png') {
      return "lib/assets/army-ranks/men.png";
    } else {
      return "lib/assets/army-ranks/soldier.png";
    }
  }

  Color soldierColorGenerator(String rank) {
    if (rank == 'lib/assets/army-ranks/rec.png' ||
        rank == 'lib/assets/army-ranks/pte.png' ||
        rank == 'lib/assets/army-ranks/lcp.png' ||
        rank == 'lib/assets/army-ranks/cpl.png' ||
        rank == 'lib/assets/army-ranks/cfc.png') {
      return Colors.brown.shade800;
    } else if (rank == 'lib/assets/army-ranks/sct.png') {
      return Colors.brown.shade400;
    } else if (rank == 'lib/assets/army-ranks/3sg.png' ||
        rank == 'lib/assets/army-ranks/2sg.png' ||
        rank == 'lib/assets/army-ranks/1sg.png' ||
        rank == 'lib/assets/army-ranks/ssg.png' ||
        rank == 'lib/assets/army-ranks/msg.png') {
      return Colors.indigo.shade800;
    } else if (rank == 'lib/assets/army-ranks/3wo.png' ||
        rank == 'lib/assets/army-ranks/2wo.png' ||
        rank == 'lib/assets/army-ranks/1wo.png' ||
        rank == 'lib/assets/army-ranks/mwo.png' ||
        rank == 'lib/assets/army-ranks/swo.png' ||
        rank == 'lib/assets/army-ranks/cwo.png') {
      return Colors.indigo.shade400;
    } else if (rank == 'lib/assets/army-ranks/oct.png') {
      return Colors.teal.shade900;
    } else if (rank == 'lib/assets/army-ranks/2lt.png' ||
        rank == 'lib/assets/army-ranks/lta.png' ||
        rank == 'lib/assets/army-ranks/cpt.png') {
      return Colors.teal.shade800;
    } else {
      return Colors.teal.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    // List colors = [
    //   Colors.brown.shade800,
    //   Colors.indigo.shade800,
    //   Colors.indigo.shade400,
    //   Colors.teal.shade800,
    //   Colors.teal.shade400,
    // ];

    //int index = math.Random().nextInt(4);

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
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    blurRadius: 2.0,
                    spreadRadius: 2.0,
                    offset: Offset(10, 10),
                    color: Colors.black54)
              ],
              color: soldierColorGenerator(soldierRank),
              borderRadius: BorderRadius.circular(12)),
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
                      color: Colors.transparent.withOpacity(0.15),
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
                  soldierIconGenerator(soldierRank),
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

              const StyledText(
                "IN CAMP",
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
