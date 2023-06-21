import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:roundcheckbox/roundcheckbox.dart';

import '../add_duty_soldiers_card.dart';

class AddSoldierToDutyTile extends StatefulWidget {
  const AddSoldierToDutyTile(
      {super.key,
      required this.rank,
      required this.name,
      required this.appointment});

  final String rank;
  final String name;
  final String appointment;

  @override
  State<AddSoldierToDutyTile> createState() => _AddSoldierToDutyTileState();
}

class _AddSoldierToDutyTileState extends State<AddSoldierToDutyTile> {
  @override
  Widget build(BuildContext context) {
    print(non_participants);
    if (non_participants.contains(widget.name)) {
      return Padding(
        padding: EdgeInsets.all(8.0.sp),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: const Color.fromARGB(255, 29, 32, 43).withOpacity(0.2),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.0.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  backgroundColor:
                      const Color.fromARGB(255, 53, 59, 79).withOpacity(0.2),
                  minRadius: 30.w,
                  child: Image.asset(
                    "lib/assets/army-ranks/${widget.rank.toString().toLowerCase()}.png",
                    width: 30.w,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 200.w,
                      child: AutoSizeText(
                        widget.name,
                        minFontSize: 16,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AutoSizeText(
                      widget.appointment,
                      maxFontSize: 12,
                      style: GoogleFonts.poppins(
                          color: Colors.white70.withOpacity(0.2),
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
    return Padding(
      padding: EdgeInsets.all(8.0.sp),
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                width: 10.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200.w,
                    child: AutoSizeText(
                      widget.name,
                      minFontSize: 16,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AutoSizeText(
                    widget.appointment,
                    maxFontSize: 12,
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              RoundCheckBox(
                size: 30.0.sp,
                borderColor: Colors.white54,
                uncheckedColor: Colors.transparent,
                onTap: (selected) {
                  if (tempArray.containsKey(widget.name)) {
                    tempArray.remove(widget.name);
                  } else {
                    tempArray.addAll(
                        {widget.name.toString(): widget.rank.toString()});
                  }

                  // if (tempArray.contains(
                  //     [widget.name.toString(), widget.rank.toString()])) {
                  //   selected = true;
                  // } else {
                  //   selected = false;
                  // }

                  print(tempArray);
                },
                checkedWidget: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 72, 30, 229),
                        Color.fromARGB(255, 130, 60, 229),
                      ],
                    ),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.check,
                      size: 15.0.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
