import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/util/tiles/current_status_detailed_screen_tile.dart';
import 'package:prototype_1/util/tiles/past_status_detailed_screen_tile.dart';

var soldierStatuses = [
  //soldierStatuses - [statusType, statusName, startDate, endDate]
  ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"],
  ["Leave", "MC", "10 Jun 2021", "12 Jul 2021"],
  ["Medical Appointment", "National Skin Centre", "5 Apr 2021", "5 Apr 2021"],
];

var pastStatuses = [
  //soldierStatuses - [statusType, statusName, startDate, endDate]
  ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"],
  ["Leave", "MC", "10 Jun 2021", "12 Jul 2021"],
  ["Medical Appointment", "National Skin Centre", "5 Apr 2021", "5 Apr 2021"],
  ["Excuse", "Ex FLEGs", "13 Jul 2021", "12 Jul 2022"],
  ["Leave", "MC", "10 Jun 2021", "12 Jul 2021"],
  ["Medical Appointment", "National Skin Centre", "5 Apr 2021", "5 Apr 2021"],
];

class UserProfileStatusesTab extends StatefulWidget {
  const UserProfileStatusesTab({
    super.key,
  });

  @override
  State<UserProfileStatusesTab> createState() => _UserProfileStatusesTabState();
}

class _UserProfileStatusesTabState extends State<UserProfileStatusesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(30.0.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_information_rounded,
                  color: Colors.white,
                  size: 30.sp,
                ),
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  "Active Statuses",
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 250.h,
              child: ListView.builder(
                itemCount: soldierStatuses.length,
                padding: EdgeInsets.all(12.sp),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return SoldierStatusTile(
                      statusType: soldierStatuses[index][0],
                      statusName: soldierStatuses[index][1],
                      startDate: soldierStatuses[index][2],
                      endDate: soldierStatuses[index][3]);
                },
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.av_timer_rounded,
                  color: Colors.white,
                  size: 30.sp,
                ),
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  "Past Statuses",
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: pastStatuses.length,
                itemBuilder: (context, index) {
                  return PastSoldierStatusTile(
                      statusType: pastStatuses[index][0],
                      statusName: pastStatuses[index][1],
                      startDate: pastStatuses[index][2],
                      endDate: pastStatuses[index][3]);
                },
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 40.0.w, vertical: 16.0.h),
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 72, 30, 229),
                          Color.fromARGB(255, 130, 60, 229),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50.0)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.note_add,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      StyledText("ADD NEW STATUS", 18.sp,
                          fontWeight: FontWeight.bold),
                    ],
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
