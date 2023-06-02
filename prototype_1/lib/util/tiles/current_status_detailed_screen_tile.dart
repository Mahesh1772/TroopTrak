import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late Color? tileColor;
late IconData? tileIcon;
List soldierStatus = ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"];

class SoldierStatusTile extends StatefulWidget {
  const SoldierStatusTile(
      {super.key,
      required this.statusType,
      required this.statusName,
      required this.startDate,
      required this.endDate,
      required this.docID,
      required this.statusID});

  final String statusType;
  final String startDate;
  final String endDate;
  final String statusName;
  final String docID;
  final String statusID;

  @override
  State<SoldierStatusTile> createState() => _SoldierStatusTileState();
}

class _SoldierStatusTileState extends State<SoldierStatusTile> {
  Future deleteCurrentStatus() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.docID)
        .collection('Statuses')
        .doc(widget.statusID)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    setTileIconAndColor(widget.statusType);

    return Padding(
      padding: EdgeInsets.all(12.0.sp),
      child: Container(
        width: 250.w,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              blurRadius: 2.0.r,
              spreadRadius: 2.0.r,
              offset: Offset(10.w, 10.h),
              color: Colors.black54)
        ], color: tileColor, borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  onTap: deleteCurrentStatus,
                  child: Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            StyledText(widget.statusName, 20.sp, fontWeight: FontWeight.bold),
            StyledText(widget.statusType.toUpperCase(), 18.sp,
                fontWeight: FontWeight.w500),
            StyledText("${widget.startDate} - ${widget.endDate}", 16.sp,
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
