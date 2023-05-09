import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SoliderDetailedScreen extends StatelessWidget {
  final String soldierName;
  final String soldierRank;
  final String soldierAttendance;
  final String soldierIcon;

  const SoliderDetailedScreen(
      {super.key,
      required this.soldierIcon,
      required this.soldierName,
      required this.soldierRank,
      required this.soldierAttendance});

  @override
  Widget build(BuildContext context) {
    final nameParts = soldierName.toUpperCase().split(' ');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 75, 32, 224),
              Color.fromARGB(255, 130, 58, 235)
            ],
          )),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 19, 27, 45),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset(
                        soldierIcon,
                        width: 90,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 240,
                        child: AutoSizeText(
                          soldierName.toUpperCase(),
                          maxLines: 2,
                          minFontSize: 24,
                          style: GoogleFonts.josefinSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              wordSpacing: 2.0),
                        ),
                      ),
                      Image.asset(
                        soldierRank,
                        width: 70,
                        color: Colors.white,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
