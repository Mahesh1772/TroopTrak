import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/add_new_duty_screen.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/tabs/points_leaderboard.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/tabs/upcoming_duties.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';

class GuardDutyTrackerScreen extends StatefulWidget {
  const GuardDutyTrackerScreen({super.key});

  @override
  State<GuardDutyTrackerScreen> createState() => _GuardDutyTrackerScreenState();
}

class _GuardDutyTrackerScreenState extends State<GuardDutyTrackerScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewDutyScreen(
                dutyDate: "Date of Duty:",
                dutyStartTime: "Start Time:",
                dutyEndTime: "End Time:",
              ),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                    child: StyledText(
                      'Guard Duty',
                      26.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(12.0.sp),
                      child: Image.asset(
                        'lib/assets/user.png',
                        width: 50.w,
                      ),
                    ),
                  ),
                ],
              ),
              TabBar(
                labelStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
                controller: tabController,
                tabs: const [
                  Tab(
                    text: "POINTS LEADERBOARD",
                    icon: Icon(
                      Icons.leaderboard_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Tab(
                    text: "UPCOMING DUTIES",
                    icon: Icon(
                      Icons.more_time_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.maxFinite,
                height: 800.h,
                child: TabBarView(
                  controller: tabController,
                  children: const [
                    //Basic Info tab
                    PointsLeaderBoard(),

                    //Statuses tab
                    UpcomingDuties(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
