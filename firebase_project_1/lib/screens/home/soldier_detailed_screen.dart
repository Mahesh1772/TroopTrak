import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_1/util/text_style.dart';
import 'package:firebase_project_1/util/soldier_detailed_screen_info_template.dart';
import 'package:recase/recase.dart';

class SoldierDetailedScreen extends StatelessWidget {
  const SoldierDetailedScreen(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 72, 30, 229),
                    Color.fromARGB(255, 130, 60, 229),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(
                                  Icons.arrow_back_sharp,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        soldierName.toUpperCase(),
                                        maxLines: 3,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        soldierAppointment.titleCase,
                                        maxLines: 2,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset(
                                  soldierRank,
                                  width: 60,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(
                              "${company.toUpperCase()} COMPANY",
                              maxLines: 2,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, bottom: 50.0),
                            child: Text(
                              "Platoon $platoon, Section $section",
                              maxLines: 2,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoldierDetailedInfoTemplate(
                  title: "Date Of Birth",
                  content: dateOfBirth.toUpperCase(),
                  icon: Icons.cake_rounded,
                ),
                SoldierDetailedInfoTemplate(
                  title: "Ration Type:",
                  content: rationType.toUpperCase(),
                  icon: Icons.food_bank_rounded,
                ),
                SoldierDetailedInfoTemplate(
                  title: "Blood Type:",
                  content: bloodType.toUpperCase(),
                  icon: Icons.bloodtype_rounded,
                ),
                SoldierDetailedInfoTemplate(
                  title: "Enlistment Date:",
                  content: enlistmentDate.toUpperCase(),
                  icon: Icons.date_range_rounded,
                ),
                SoldierDetailedInfoTemplate(
                  title: "ORD:",
                  content: ordDate.toUpperCase(),
                  icon: Icons.military_tech_rounded,
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: TextButton(
                    onPressed: () {},
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
                  height: 50,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
