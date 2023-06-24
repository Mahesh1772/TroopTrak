import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/update_duty_screen.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/expanded_view_duty_participants_tile.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';

import '../../nominal_roll_screen/nominal_roll_screen_new.dart';

class GuardDutyTile extends StatelessWidget {
  final String dutyDate;
  final String startTime;
  final String endTime;
  final String dutyType;
  final double numberOfPoints;

  const GuardDutyTile(
      {super.key,
      required this.dutyDate,
      required this.startTime,
      required this.endTime,
      required this.dutyType,
      required this.numberOfPoints});

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 30.0.w),
                child: Container(
                  height: 80.h,
                  width: 80.w,
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
                          numberOfPoints.toString(),
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
                    width: 200.w,
                    child: AutoSizeText(
                      '$startTime - $endTime (Next day)',
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 200.w,
                    child: AutoSizeText(
                      dutyDate,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
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
                itemCount: userDetails.length,
                padding: EdgeInsets.all(12.sp),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return ExpandedDutyParticipantsTile(
                    soldierName: userDetails[index]['name'],
                    soldierRank: userDetails[index]['rank'],
                    soldierAppointment: userDetails[index]['appointment'],
                    company: userDetails[index]['company'],
                    platoon: userDetails[index]['platoon'],
                    section: userDetails[index]['section'],
                    dateOfBirth: userDetails[index]['dob'],
                    rationType: userDetails[index]['rationType'],
                    bloodType: userDetails[index]['bloodgroup'],
                    enlistmentDate: userDetails[index]['enlistment'],
                    ordDate: userDetails[index]['ord'],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateDutyScreen(
                              dutyDate: dutyDate,
                              dutyStartTime: startTime,
                              dutyEndTime: endTime)));
                },
                child: Container(
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 72, 30, 229),
                        Color.fromARGB(255, 130, 60, 229),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_document,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        AutoSizeText(
                          'EDIT DUTY',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 229, 30, 33),
                        Color.fromARGB(255, 215, 93, 99),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        AutoSizeText(
                          'DELETE DUTY',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
