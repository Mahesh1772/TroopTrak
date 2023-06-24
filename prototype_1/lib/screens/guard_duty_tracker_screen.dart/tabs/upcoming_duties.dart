import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/guard_duty_main_page_tiles.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';

class UpcomingDuties extends StatefulWidget {
  const UpcomingDuties({super.key});

  @override
  State<UpcomingDuties> createState() => _UpcomingDutiesState();
}

class _UpcomingDutiesState extends State<UpcomingDuties> {
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> upcomingDuties = [
      {
        'dutyDate': '14 Jul 2023',
        'startTime': '8:00 AM',
        'endTime': '8:00 AM',
        'dutyType': 'Weekend (Saturday, 24hrs) Duty',
        'points': 2.5
      },
      {
        'dutyDate': '30 Jun 2023',
        'startTime': '5:00 PM',
        'endTime': '8:00 AM',
        'dutyType': 'Weekday (12hrs) Duty',
        'points': 1.0
      },
      {
        'dutyDate': '14 Aug 2023',
        'startTime': '8:00 AM',
        'endTime': '8:00 AM',
        'dutyType': 'Weekend (Sunday, 24hrs) Duty',
        'points': 2.0
      },
    ];
    return Container(
      margin: EdgeInsets.only(top: 50.h),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0.w),
              child: StyledText("Upcoming Duties", 24.sp,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 15.h,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: upcomingDuties.length,
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {},
                    child: GuardDutyTile(
                        dutyDate: upcomingDuties[index]['dutyDate'],
                        startTime: upcomingDuties[index]['startTime'],
                        endTime: upcomingDuties[index]['endTime'],
                        dutyType: upcomingDuties[index]['dutyType'],
                        numberOfPoints: upcomingDuties[index]['points']));
              },
            ),
            SizedBox(
              height: 10.h,
            )
          ],
        ),
      ),
    );
  }
}
