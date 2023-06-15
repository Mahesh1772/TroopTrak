import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:prototype_1/screens/detailed_screen/tabs/statuses_screen/update_status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late IconData? tileIcon;

class PastSoldierStatusTile extends StatefulWidget {
  const PastSoldierStatusTile({
    super.key,
    required this.statusType,
    required this.statusName,
    required this.startDate,
    required this.endDate,
    required this.docID,
    required this.statusID,
  });

  final String statusType;
  final String startDate;
  final String endDate;
  final String statusName;
  final String docID;
  final String statusID;
  @override
  State<PastSoldierStatusTile> createState() => _PastSoldierStatusTileState();
}

class _PastSoldierStatusTileState extends State<PastSoldierStatusTile> {
  @override
  Widget build(BuildContext context) {
    Future deletePastStatus() async {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.docID)
          .collection('Statuses')
          .doc(widget.statusID)
          .delete();
    }

    setTileIcon(widget.statusType);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateStatusScreen(
                      statusID: widget.statusID,
                      docID: widget.docID,
                      selectedStatusType: widget.statusType,
                      statusName:
                          TextEditingController(text: widget.statusName.toString()),
                      startDate: widget.startDate,
                      endDate: widget.endDate,
                    ),
                  ),
                );
              },
              icon: Icons.info_rounded,
              backgroundColor: Colors.blue,
            ),
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
            color: const Color.fromARGB(104, 158, 158, 158),
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
                //SizedBox(width: 20),
                SizedBox(
                  width: 100.w,
                  child: AutoSizeText(
                    widget.statusName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 200.w,
                  child: AutoSizeText(
                    "$widget.startDate - $widget.endDate",
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
}

setTileIcon(String type) {
  if (type == "Excuse") {
    tileIcon = Icons.personal_injury_rounded;
  } else if (type == "Leave") {
    tileIcon = Icons.medical_services_rounded;
  } else if (type == "Medical Appointment") {
    tileIcon = Icons.date_range_rounded;
  }
}
