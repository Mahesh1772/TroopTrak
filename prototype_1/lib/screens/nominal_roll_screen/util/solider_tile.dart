// ignore_for_file: must_be_immutable

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/user_models/user_details.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/screens/detailed_screen/soldier_detailed_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:provider/provider.dart';

class SoldierTile extends StatefulWidget {
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
  late bool isInsideCamp;

  SoldierTile({
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
    required this.isInsideCamp,
  });

  @override
  State<SoldierTile> createState() => _SoldierTileState();
}

class _SoldierTileState extends State<SoldierTile> {
  bool loading = false;
  String inCampStatusText = '';
  List<Map<String, dynamic>> all_data = [];
  bool last_value = false;

  Future addAttendanceDetails(bool i) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.soldierName)
        .collection('Attendance')
        .add({
      //User map formatting
      'isInsideCamp': i,
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(DateTime.now()),
    });
  }

  int i = 0;
  Future getAttendance() async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.soldierName)
        .collection("Attendence")
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        Map<String, dynamic> data = snapshot.data();
        all_data.add(data);
        all_data[i].addEntries({'ID': snapshot.id}.entries);
        print(data);
        i++;
      }
    });
  }

  @override
  void initState() {
    inCampStatusText = inCampStatusTextChanger(widget.isInsideCamp);
    getAttendance();
    print(all_data);
    super.initState();
  }

  String inCampStatusTextChanger(bool value) {
    if (value) {
      return "IN CAMP";
    }
    return "NOT IN CAMP";
  }

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
      return Colors.indigo.shade700;
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
    getAttendance();
    all_data.last['isInsideCamp'] = last_value;
    Color tileColor = soldierColorGenerator(
        "lib/assets/army-ranks/${widget.soldierRank.toString().toLowerCase()}.png");
    return OpenContainer(
      closedBuilder: (context, action) {
        return Padding(
          padding: EdgeInsets.all(8.0.sp),
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  blurRadius: 2.0.r,
                  spreadRadius: 2.0.r,
                  offset: Offset(10.w, 10.h),
                  color: Colors.black54)
            ], color: tileColor, borderRadius: BorderRadius.circular(12.r)),
            child: Column(
              children: [
                //rank insignia
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      padding: EdgeInsets.all(5.sp),
                      decoration: BoxDecoration(
                        color: Colors.transparent.withOpacity(0.15),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12.r),
                            bottomLeft: Radius.circular(12.r)),
                      ),
                      child: Image.asset(
                        "lib/assets/army-ranks/${widget.soldierRank.toString().toLowerCase()}.png",
                        color: rankColorPicker(widget.soldierRank)
                            ? Colors.white70
                            : null,
                      ),
                    ),
                  ],
                ),

                //soldier icon
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 8.0.h),
                  child: Image.asset(
                    soldierIconGenerator(
                        "lib/assets/army-ranks/${widget.soldierRank.toString().toLowerCase()}.png"),
                    width: 90.w,
                  ),
                ),

                //name

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                  child: SizedBox(
                    height: 40.h,
                    width: double.maxFinite,
                    child: Center(
                        child: AutoSizeText(
                      widget.soldierName,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
                  ),
                ),

                SizedBox(
                  height: 10.h,
                ),

                StyledText(inCampStatusText, 14.sp,
                    fontWeight: FontWeight.w400),

                SizedBox(
                  height: 15.h,
                ),

                AnimatedToggleSwitch<bool>.rolling(
                  current: last_value,
                  allowUnlistedValues: true,
                  values: const [false, true],
                  onChanged: (i) {
                    setState(() {
                      i = last_value;
                      inCampStatusText = inCampStatusTextChanger(i);
                      addAttendanceDetails(i);
                    });
                  },
                  iconBuilder: rollingIconBuilder,
                  borderWidth: 3.0.w,
                  indicatorColor: Colors.white,
                  innerGradient: LinearGradient(colors: [
                    Colors.transparent.withOpacity(0.1),
                    Colors.transparent.withOpacity(0),
                  ]),
                  innerColor: Colors.amber,
                  height: 40.h,
                  dif: 10.w,
                  iconRadius: 10.0.r,
                  selectedIconRadius: 13.0.r,
                  borderColor: Colors.transparent,
                  loading: loading,
                  foregroundBoxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1.r,
                      blurRadius: 2.r,
                      offset: Offset(0.w, 1.5.h),
                    )
                  ],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1.r,
                      blurRadius: 2.r,
                      offset: Offset(0.w, 1.5.h),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
      openBuilder:
          (BuildContext context, void Function({Object? returnValue}) action) {
        return SoldierDetailedScreen(
          soldierName: widget.soldierName,
          soldierRank: widget.soldierRank,
          company: widget.company,
          platoon: widget.platoon,
          section: widget.section,
          dateOfBirth: widget.dateOfBirth,
          enlistmentDate: widget.enlistmentDate,
          ordDate: widget.ordDate,
          soldierAppointment: widget.soldierAppointment,
          rationType: widget.rationType,
          bloodType: widget.bloodType,
        );
      },
      closedColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 50),
    );
  }
}

Widget rollingIconBuilder(bool value, Size iconSize, bool foreground) {
  IconData data;

  if (value) {
    data = Icons.check_circle;
  } else {
    data = Icons.cancel;
  }
  return Icon(
    data,
    size: iconSize.shortestSide,
  );
}
