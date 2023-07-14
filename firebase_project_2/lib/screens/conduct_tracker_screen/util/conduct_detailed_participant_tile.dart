// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ConductDetailedParticipantTile extends StatefulWidget {
  const ConductDetailedParticipantTile({
    super.key,
    required this.rank,
    required this.name,
  });

  final String rank;
  final String name;

  @override
  State<ConductDetailedParticipantTile> createState() =>
      _ConductDetailedParticipantTileState();
}

class _ConductDetailedParticipantTileState
    extends State<ConductDetailedParticipantTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black87,
              offset: Offset(5.w, 2.h),
              blurRadius: 2.0.r,
              spreadRadius: 2.0.r,
            ),
          ],
          color: const Color.fromARGB(255, 29, 32, 43),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 53, 59, 79),
                minRadius: 30.w,
                child: Image.asset(
                  "lib/assets/army-ranks/${widget.rank.toString().toLowerCase()}.png",
                  width: 30.w,
                  color: Colors.white,
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
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  StyledText("PARTICIPANT", 14.sp, fontWeight: FontWeight.w400)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
