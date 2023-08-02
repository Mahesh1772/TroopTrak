import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/add_new_duty_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/tabs/points_leaderboard.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/tabs/upcoming_duties.dart';

class GuardDutyTrackerScreen extends StatefulWidget {
  const GuardDutyTrackerScreen({super.key});

  @override
  State<GuardDutyTrackerScreen> createState() => _GuardDutyTrackerScreenState();
}

class _GuardDutyTrackerScreenState extends State<GuardDutyTrackerScreen>
    with TickerProviderStateMixin {
  // The DocID or the name of the current user is saved in here
  final name = FirebaseAuth.instance.currentUser!.displayName.toString();

  Map<String, dynamic> currentUserData = {};

  List<Map<String, dynamic>> statusList = [];
  List<String> nonParticipants = [];

  Future getCurrentUserData() async {
    var data = FirebaseFirestore.instance.collection('Users').doc(name);
    data.get().then((DocumentSnapshot doc) {
      currentUserData = doc.data() as Map<String, dynamic>;
      // ...
    });
  }

  refreshCallback() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
  }

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
                listOfNonparts: nonParticipants,
                refreshCallback: refreshCallback,
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                labelStyle: GoogleFonts.poppins(
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
                    ),
                  ),
                  Tab(
                    text: "UPCOMING DUTIES",
                    icon: Icon(
                      Icons.more_time_rounded,
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
