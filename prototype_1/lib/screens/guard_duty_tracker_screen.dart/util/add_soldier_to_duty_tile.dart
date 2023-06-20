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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
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
          padding: const EdgeInsets.all(10.0),
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
                size: 30.0,
                borderColor: Colors.white54,
                onTap: (selected) {},
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
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.check,
                      size: 15.0,
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
