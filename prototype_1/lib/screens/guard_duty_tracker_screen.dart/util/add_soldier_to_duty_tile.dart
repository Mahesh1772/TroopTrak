// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:roundcheckbox/roundcheckbox.dart';

class AddSoldierToDutyTile extends StatefulWidget {
  const AddSoldierToDutyTile(
      {super.key,
      required this.rank,
      required this.name,
      required this.appointment,
      required this.nonParticipants,
      required this.selectedSoldiers,
      required this.isTileSelected,
      required this.tileSelectionCallback});

  final String rank;
  final String name;
  final String appointment;
  final List nonParticipants;
  final bool isTileSelected;
  final Map<String, String> selectedSoldiers;
  final Function tileSelectionCallback;

  @override
  State<AddSoldierToDutyTile> createState() => _AddSoldierToDutyTileState();
}

class _AddSoldierToDutyTileState extends State<AddSoldierToDutyTile> {
  bool rankColorPicker(String rank) {
    return (rank == 'REC' ||
        rank == 'PTE' ||
        rank == 'LCP' ||
        rank == 'CPL' ||
        rank == 'CFC' ||
        rank == '3SG' ||
        rank == '2SG' ||
        rank == '1SG' ||
        rank == 'SSG' ||
        rank == 'MSG' ||
        rank == '3WO' ||
        rank == '2WO' ||
        rank == '1WO' ||
        rank == 'MWO' ||
        rank == 'SWO' ||
        rank == 'CWO');
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.nonParticipants);
    if (widget.nonParticipants.contains(widget.name)) {
      return Padding(
        padding: EdgeInsets.all(8.0.sp),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: const Color.fromARGB(255, 29, 32, 43).withOpacity(0.35),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.0.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  backgroundColor:
                      const Color.fromARGB(255, 53, 59, 79).withOpacity(0.35),
                  minRadius: 30.w,
                  child: Image.asset(
                    "lib/assets/army-ranks/${widget.rank.toString().toLowerCase()}.png",
                    width: 30.w,
                    color: rankColorPicker(widget.rank) ? Colors.white70 : null,
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
                  color: rankColorPicker(widget.rank) ? Colors.white : null,
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
                isChecked: widget.isTileSelected,
                size: 30.0.sp,
                borderColor: Colors.white54,
                uncheckedColor: Colors.transparent,
                onTap: (selected) {
                  if (widget.selectedSoldiers.containsKey(widget.name)) {
                    widget.selectedSoldiers.remove(widget.name);
                  } else {
                    widget.selectedSoldiers.addAll(
                        {widget.name.toString(): widget.rank.toString()});
                  }

                  widget.tileSelectionCallback(widget.selectedSoldiers);

                  print(widget.selectedSoldiers);
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
