// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ConductDetailedNonParticipantTile extends StatefulWidget {
  const ConductDetailedNonParticipantTile({
    super.key,
    required this.rank,
    required this.name,
  });

  final String rank;
  final String name;

  @override
  State<ConductDetailedNonParticipantTile> createState() =>
      _ConductDetailedNonParticipantTileState();
}

class _ConductDetailedNonParticipantTileState
    extends State<ConductDetailedNonParticipantTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0.sp),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: const Color.fromARGB(255, 29, 32, 43).withOpacity(0.35),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    const Color.fromARGB(255, 53, 59, 79).withOpacity(0.35),
                minRadius: 30.w,
                child: Image.asset(
                  "lib/assets/army-ranks/${widget.rank.toString().toLowerCase()}.png",
                  width: 30.w,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
              SizedBox(
                width: 30.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 240.w,
                    child: AutoSizeText(
                      widget.name,
                      minFontSize: 16,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.35),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AutoSizeText(
                    "Ineligible: ",
                    maxFontSize: 12,
                    style: GoogleFonts.poppins(
                        color: Colors.white70.withOpacity(0.35),
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
