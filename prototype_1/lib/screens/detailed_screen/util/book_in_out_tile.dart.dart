import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BookInOutTile extends StatefulWidget {
  const BookInOutTile({
    super.key,
    required this.timeStamp,
    required this.isInsideCamp,
    required this.docID,
    required this.attendanceID
  });

  final String timeStamp;
  final bool isInsideCamp;
  final String docID;
  final String attendanceID;

  //final String docID;

  @override
  State<BookInOutTile> createState() => _BookInOutTileState();
}

class _BookInOutTileState extends State<BookInOutTile> {
  Future deletePastStatus() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.docID)
        .collection('Attendance')
        .doc(widget.attendanceID)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    late IconData? tileIcon;
    late Color tileColor;
    tileIcon = setTileIcon(widget.isInsideCamp);
    tileColor = setTileColor(widget.isInsideCamp);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                deletePastStatus();
              },
              icon: Icons.delete_forever_rounded,
              backgroundColor: Colors.red,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  tileIcon,
                  color: Colors.white,
                  size: 30.sp,
                ),
                SizedBox(width: 20.w),
                SizedBox(
                  width: 100.w,
                  child: AutoSizeText(
                    widget.isInsideCamp ? "BOOK IN" : "BOOK OUT",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 180.w,
                  child: AutoSizeText(
                    widget.timeStamp,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: Colors.white),
                    maxLines: 1,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color setTileColor(bool isInsideCamp) {
    if (isInsideCamp) {
      return Colors.green.shade600;
    } else {
      return Colors.red;
    }
  }

  IconData? setTileIcon(bool type) {
    if (type) {
      return Icons.work_history;
    } else {
      return Icons.home;
    }
  }
}
