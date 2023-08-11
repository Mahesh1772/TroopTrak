import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/screens/guard_duty_tracker_screen.dart/util/expanded_view_duty_participants_tile.dart';
import 'package:firebase_project_2/util/constants.dart';
import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class GuardDutyTile extends StatefulWidget {
  final String dutyDate;
  final String startTime;
  final String endTime;
  final String dutyType;
  final double numberOfPoints;
  final String docID;
  final Map<String, dynamic> participants;

  GuardDutyTile({
    super.key,
    required this.dutyDate,
    required this.startTime,
    required this.endTime,
    required this.dutyType,
    required this.numberOfPoints,
    required this.docID,
    required this.participants,
  });

  @override
  State<GuardDutyTile> createState() => _GuardDutyTileState();
}

class _GuardDutyTileState extends State<GuardDutyTile>
    with TickerProviderStateMixin {
  late AnimationController _isParticipatingIconController;
  final name = FirebaseAuth.instance.currentUser!.displayName.toString();
  late bool isUserParticipating;

  @override
  void initState() {
    _isParticipatingIconController = AnimationController(
      vsync: this,
    );

    print(widget.participants);

    isUserParticipating = isPartcipant(widget.participants, name);

    _isParticipatingIconController.repeat(period: Duration(seconds: 2));
    super.initState();
  }

  bool isPartcipant(Map<String, dynamic> todayConducts, String name) {
    if (todayConducts.keys.contains(name)) {
      return true;
    }
    return false;
  }

  Future deleteDutyDetails() async {
    await FirebaseFirestore.instance
        .collection('Duties')
        .doc(widget.docID)
        .delete();
  }

  deleteDuty() {
    deleteDutyDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0.sp),
      child: Container(
        margin: EdgeInsets.only(
          top: defaultPadding.h,
        ),
        padding: EdgeInsets.all(defaultPadding.sp),
        decoration: BoxDecoration(
          border: Border.all(width: 2.w, color: Colors.white.withOpacity(0.15)),
          borderRadius: BorderRadius.all(
            Radius.circular(defaultPadding.r),
          ),
        ),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 20.0.w),
                child: Container(
                  height: 85.h,
                  width: 85.w,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 53, 14, 145),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 8.0.h),
                          child: Text(
                            "POINTS",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp),
                          ),
                        ),
                        Text(
                          widget.numberOfPoints.toString(),
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 134.w,
                    child: AutoSizeText(
                      '${widget.startTime} - ${widget.endTime}\n(Next day)',
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  SizedBox(
                    width: 134.w,
                    child: AutoSizeText(
                      widget.dutyDate,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              Center(
                child: isUserParticipating
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(18.0.sp),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                            Lottie.network(
                                "https://lottie.host/220b2467-17d5-41d3-923a-3124581b9c71/VmZrHlNeR7.json",
                                controller: _isParticipatingIconController,
                                height: 55.h,
                                fit: BoxFit.cover),
                          ],
                        ),
                      )
                    : Lottie.network(
                        "https://lottie.host/b9ea1c18-05fc-4fba-b566-cebdaecc45b5/8ZFPRtgKqI.json",
                        height: 60.h,
                        fit: BoxFit.cover),
              )
            ],
          ),
          children: [
            SizedBox(
              height: 10.h,
            ),
            StyledText(
              "Participants",
              24.sp,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 220.h,
              child: ListView.builder(
                itemCount: widget.participants.length,
                padding: EdgeInsets.all(12.sp),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ExpandedDutyParticipantsTile(
                    soldierName: widget.participants.keys.elementAt(index),
                    soldierRank: widget.participants.values.elementAt(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
