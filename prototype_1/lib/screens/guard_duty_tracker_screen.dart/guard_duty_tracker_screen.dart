import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/add_new_duty_screen.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/tabs/points_leaderboard.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/tabs/upcoming_duties.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';

import '../detailed_screen/tabs/user_profile_tabs/user_profile_screen.dart';

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
  List<String> non_participants = [];

  List<String> guardDuty = ['Ex Uniform', 'Ex Boots'];
  // void autoFilter() {
  //   if (statusList.isNotEmpty) {
  //     for (var element in statusList) {
  //       non_participants.add(element['Name']);
  //     }
  //for (var status in statusList) {
  //  if (status['statusType'] == 'Excuse') {
  //    if (guardDuty.contains(status['statusName'])) {
  //      non_participants.add(status['Name']);
  //    }
  //  } else if (status['statusType'] == 'Leave') {
  //    non_participants.add(status['Name']);
  //  }
  //}
  //   }
  // }

  // Future getUserBooks() async {
  //   int i = 0;
  //   await FirebaseFirestore.instance
  //       .collection("Users")
  //       .get()
  //       .then((querySnapshot) async {
  //     for (var snapshot in querySnapshot.docs) {
  //       FirebaseFirestore.instance
  //           .collection("Users")
  //           .doc(snapshot.id)
  //           .collection("Statuses")
  //           .where('statusType', isEqualTo: 'Excuse')
  //           .where('statusName', whereIn: ['Ex Boots', 'Ex Uniform'])
  //           .get()
  //           .then((querySnapshot) {
  //             for (var result in querySnapshot.docs) {
  //               Map<String, dynamic> data = result.data();
  //               DateTime end = DateFormat("d MMM yyyy").parse(data['endDate']);
  //               if (DateTime(end.year, end.month, end.day + 1)
  //                   .isAfter(DateTime.now())) {
  //                 statusList.add(data);
  //                 statusList[i].addEntries({'Name': snapshot.id}.entries);
  //                 i++;
  //               }
  //             }
  //           });
  //     }
  //   });
  // }

  Future getCurrentUserData() async {
    var data = FirebaseFirestore.instance.collection('Users').doc(name);
    data.get().then((DocumentSnapshot doc) {
      currentUserData = doc.data() as Map<String, dynamic>;
      // ...
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   getCurrentUserData();
  //   getUserBooks();
  //   Future.delayed(Duration(seconds: 2));
  //   autoFilter();
  //   Future.delayed(Duration(seconds: 2));
  //   print(statusList);
  // }

  @override
  Widget build(BuildContext context) {
    //getUserBooks();
    print(statusList);
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
                listOfNonparts:
                    non_participants.isNotEmpty ? non_participants : [],
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            soldierName: currentUserData['name'],
                            soldierRank: currentUserData['rank']
                                .toString()
                                .toLowerCase(),
                            soldierAppointment: currentUserData['appointment'],
                            company: currentUserData['company'],
                            platoon: currentUserData['platoon'],
                            section: currentUserData['section'],
                            dateOfBirth: currentUserData['dob'],
                            rationType: currentUserData['rationType'],
                            bloodType: currentUserData['bloodgroup'],
                            enlistmentDate: currentUserData['enlistment'],
                            ordDate: currentUserData['ord'],
                          ),
                        ),
                      );
                    },
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
