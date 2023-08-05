import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late Color? tileColor;
late IconData? tileIcon;

class SoldierStatusTile extends StatefulWidget {
  const SoldierStatusTile(
      {super.key,
      required this.statusType,
      required this.statusName,
      required this.startDate,
      required this.endDate,
      required this.docID,
      required this.statusID,
      required this.end_date,
      required this.start_date});

  final String statusType;
  final String startDate;
  final String endDate;
  final String statusName;
  final String docID;
  final String statusID;
  final String start_date;
  final String end_date;

  @override
  State<SoldierStatusTile> createState() => _SoldierStatusTileState();
}

CollectionReference db = FirebaseFirestore.instance.collection('Users');

class _SoldierStatusTileState extends State<SoldierStatusTile> {
  Future deleteCurrentStatus() async {
    await db
        .doc(widget.docID)
        .collection('Statuses')
        .doc(widget.statusID)
        .delete();
  }

  Future deleteAttendanceDetails(String attendance_id) async {
    await db
        .doc(widget.docID)
        .collection('Attendance')
        .doc(attendance_id)
        .delete();
  }

  Future deleteDetails() async {
    //DateTime end = DateFormat("d MMM yyyy").parse(widget.startDate);
    //DateTime start = DateFormat("d MMM yyyy").parse(widget.endDate);
    //start = DateTime(
    //start.year, start.month, start.day, start.hour, start.minute + 30);
    //end = DateTime(end.year, end.month, end.day, 22, 0, 0);
    await deleteCurrentStatus();
    await deleteAttendanceDetails(widget.start_date);
    await deleteAttendanceDetails(widget.end_date);
  }

  @override
  Widget build(BuildContext context) {
    setTileIconAndColor(widget.statusType);

    return Padding(
      padding: EdgeInsets.all(15.0.sp),
      child: Container(
        width: 230.w,
        height: 300.h,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              blurRadius: 2.0.r,
              spreadRadius: 2.0.r,
              offset: Offset(10.w, 10.h),
              color: Colors.black54)
        ], color: tileColor, borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  tileIcon,
                  color: Colors.white,
                  size: 60.sp,
                ),
                InkWell(
                  onTap: () async {
                    //print(widget.docID);
                    await deleteDetails();
                  },
                  child: Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            SizedBox(
              height: 30,
              width: 90,
              child: AutoSizeText(
                widget.statusName,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
            //const SizedBox(
            //  height: 5,
            //),
            StyledText(widget.statusType.toUpperCase(), 15.sp,
                fontWeight: FontWeight.w500),
            //const SizedBox(
            //  height: 5,
            //),
            StyledText("${widget.startDate} - ${widget.endDate}", 15.sp,
                fontWeight: FontWeight.bold)
          ],
        ),
      ),
    );
  }
}

setTileIconAndColor(String type) {
  if (type == "Excuse") {
    tileColor = Colors.amber[900];
    tileIcon = Icons.personal_injury_rounded;
  } else if (type == "Leave") {
    tileColor = Colors.red;
    tileIcon = Icons.medical_services_rounded;
  } else if (type == "Medical Appointment") {
    tileColor = Colors.blue[600];
    tileIcon = Icons.date_range_rounded;
  }
}
