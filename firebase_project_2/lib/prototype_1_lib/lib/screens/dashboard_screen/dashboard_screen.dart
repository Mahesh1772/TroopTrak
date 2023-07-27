// ignore_for_file: must_be_immutable
import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/dashboard_screen/util/calendar/dashboard_calendar.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/dashboard_screen/util/current_strength_breakdown_tile.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/constants.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/dashboard_screen/util/pie_chart/current_strength_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/user_profile_tabs/user_profile_screen.dart';
import 'package:flip_card/flip_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> userDetails = [];

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> specDetails = [];

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> officerDetails = [];

// List to store all user data, whilst also mapping to name
//List<Map<String, dynamic>> statusDetails = [];
//
//// List to store all user data, whilst also mapping to name
//List<Map<String, dynamic>> _maDetails = [];

Map<String, dynamic> currentUserData = {};

// All this was supposed to be in another file
List statusList = [];

// All this was supposed to be in another file
List _maList = [];

int i = 0;

// Will be used to count the no. of people scanned thru
int counter = 0;

//This is what the stream builder is waiting for
late Stream<QuerySnapshot> documentStream;

// The list of all document IDs,
//which have access to each their own personal information
List<String> documentIDs = [];

final FlipCardController _controller = FlipCardController();

class _DashboardScreenState extends State<DashboardScreen> {
  void cardFlipAnimations() {
    _controller.hint(
      duration: const Duration(seconds: 2),
      total: const Duration(seconds: 4),
    );
  }

  List<String> specialist = [
    "REC",
    "PTE",
    "LCP",
    "CPL",
    "CFC",
    "SCT",
    "OCT",
    "3SG",
    "2SG",
    "1SG",
    "SSG",
    "MSG",
    "3WO",
    "2WO",
    "1WO",
    "MWO",
    "SWO",
    "CWO",
  ];

  List<String> officers = [
    "2LT",
    "LTA",
    "CPT",
    "MAJ",
    "LTC",
    "SLTC",
    "COL",
    "BG",
    "MG",
    "LG",
  ];

  final name = FirebaseAuth.instance.currentUser!.displayName.toString();

  Future getCurrentUserData() async {
    var data = FirebaseFirestore.instance.collection('Users').doc(name);
    data.get().then((DocumentSnapshot doc) {
      currentUserData = doc.data() as Map<String, dynamic>;
      // ...
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    statusList = [];
    _maList = [];
    List<Map<String, dynamic>> _maDetails = [];
    List<Map<String, dynamic>> statusDetails = [];
    //Future.delayed(Duration(seconds: 4));
    Map<String, dynamic> fullList = {};

    int inCamp(List userDetails, bool isStatusPersonal) {
      int insideCamp = 0;

      for (var user in userDetails) {
        if (fullList[user['name']]) {
          insideCamp += 1;
        }
      }

      if (isStatusPersonal) {
        insideCamp = userDetails.length;
      }
      return insideCamp;
    }

    final statusModel = Provider.of<UserData>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 21, 25, 34),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                      child: StyledText(
                        'Dashboard',
                        26.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      key: const Key("userProfileIcon"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(
                              soldierName: currentUserData['name'],
                              soldierRank: currentUserData['rank']
                                  .toString()
                                  .toLowerCase(),
                              soldierAppointment:
                                  currentUserData['appointment'],
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
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                  child: StyledText(
                    'Welcome,\n$name! 👋',
                    32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: statusModel.data,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      userDetails = [];
                      officerDetails = [];
                      specDetails = [];
                      fullList = {};
                      counter = 0;

                      // Create a Completer to delay the execution until we have collected data from all 'Statuses' subcollections
                      Completer<void> completer = Completer<void>();
                      List? users = snapshot.data?.docs.toList();
                      var docsmapshot = snapshot.data!;
                      print(users!.length);

                      for (var i = 0; i < users!.length; i++) {
                        final uid = users[i]['name'];
                        counter++;
                        var data = docsmapshot.docs[i].data()
                            as Map<String, dynamic>;
                        userDetails.add(data);
                        if (specialist.contains(data['rank'])) {
                          specDetails.add(data);
                        } else if (officers.contains(data['rank'])) {
                          officerDetails.add(data);
                        }
                        bool val = data['currentAttendance'] == 'Outside'
                            ? false
                            : true;
                        fullList.addAll({data['name']: val});

                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(uid)
                            .collection('Statuses')
                            .snapshots()
                            .listen((statusesSnapshot) {
                          if (statusesSnapshot.docs.isNotEmpty) {
                            statusesSnapshot.docs.forEach((element) {
                              var statusData = element.data();
                              DateTime end = DateFormat("d MMM yyyy")
                                  .parse(statusData['endDate']);
                              if (DateTime(end.year, end.month, end.day + 1)
                                  .isAfter(DateTime.now())) {
                                if (statusData['statusType'] ==
                                    'Medical Appointment') {
                                  //_maList.add(uid);

                                  _maDetails
                                      .add(Map<String, dynamic>.from(data));
                                } else {
                                  // statusList.add(uid);

                                  statusDetails
                                      .add(Map<String, dynamic>.from(data));
                                }
                              }
                              //statusDetails.add(data);
                            });
                            if (counter == users.length) {
                              completer.complete();
                            }
                          }
                        });
                      }

                      return FutureBuilder<void>(
                          future: completer.future,
                          //stream: Stream.empty(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              statusDetails =
                                  LinkedHashSet<Map<String, dynamic>>.from(
                                          statusDetails)
                                      .toList();
                              _maDetails =
                                  LinkedHashSet<Map<String, dynamic>>.from(
                                          _maDetails)
                                      .toList();
                              //print(statusDetails);
                              //print(_maDetails);
                              return FlipCard(
                                controller: _controller,
                                front: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: defaultPadding.w),
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(defaultPadding.sp),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54,
                                            offset: Offset(10.0.w, 10.0.h),
                                            blurRadius: 2.0.r,
                                            spreadRadius: 2.0.r),
                                      ],
                                      color: const Color.fromARGB(
                                          255, 32, 36, 51),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.r)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Strength In-Camp",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 24.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  "As of ${DateFormat('yMMMMd').add_Hm().format(DateTime.now())}",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white
                                                          .withOpacity(0.45)),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                top: 16.0.h,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      _controller
                                                          .toggleCard();
                                                    },
                                                    child: Icon(
                                                      Icons
                                                          .date_range_rounded,
                                                      color: Colors.white,
                                                      size: 30.sp,
                                                    ),
                                                  ),
                                                  StyledText(
                                                      "Show Calendar", 14.sp,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: (defaultPadding + 2).h,
                                        ),
                                        CurrentStrengthChart(
                                          currentOfficers:
                                              inCamp(officerDetails, false),
                                          currentWOSEs:
                                              inCamp(specDetails, false),
                                          currentStatus:
                                              inCamp(statusDetails, true),
                                          currentMA: inCamp(_maDetails, true),
                                          totalOfficers:
                                              officerDetails.length,
                                          totalWOSEs: specDetails.length,
                                        ),
                                        SizedBox(
                                          height: defaultPadding.h,
                                        ),
                                        CurrentStrengthBreakdownTile(
                                          title: "Total Officers",
                                          imgSrc:
                                              "lib/assets/icons8-medals-64.png",
                                          currentNumOfSoldiers:
                                              inCamp(officerDetails, false),
                                          totalNumOfSoldiers:
                                              officerDetails.length,
                                          imgColor: Colors.red,
                                          userDetails: officerDetails,
                                          fullList: fullList,
                                        ),
                                        CurrentStrengthBreakdownTile(
                                          title: "Total WOSEs",
                                          imgSrc:
                                              "lib/assets/icons8-soldier-man-64.png",
                                          currentNumOfSoldiers:
                                              inCamp(specDetails, false),
                                          totalNumOfSoldiers:
                                              specDetails.length,
                                          imgColor: Colors.blue,
                                          userDetails: specDetails,
                                          fullList: fullList,
                                        ),
                                        CurrentStrengthBreakdownTile(
                                          title: "On Status",
                                          imgSrc:
                                              "lib/assets/icons8-error-64.png",
                                          currentNumOfSoldiers:
                                              statusDetails.length,
                                          //inCamp(statusDetails, true),
                                          totalNumOfSoldiers:
                                              (officerDetails.length +
                                                  specDetails.length),
                                          imgColor: Colors.yellow,
                                          userDetails: statusDetails,
                                          fullList: fullList,
                                        ),
                                        CurrentStrengthBreakdownTile(
                                          title: "On MA",
                                          imgSrc:
                                              "lib/assets/icons8-doctors-folder-64.png",
                                          currentNumOfSoldiers:
                                              _maDetails.length,
                                          //inCamp(_maDetails, false),
                                          totalNumOfSoldiers:
                                              (officerDetails.length +
                                                  specDetails.length),
                                          imgColor: Colors.lightBlueAccent,
                                          userDetails: _maDetails,
                                          fullList: fullList,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                back: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: defaultPadding.w),
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(defaultPadding.sp),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54,
                                            offset: Offset(10.0.w, 10.0.h),
                                            blurRadius: 2.0.r,
                                            spreadRadius: 2.0.r),
                                      ],
                                      color: const Color.fromARGB(
                                          255, 32, 36, 51),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.r)),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        DashboardCalendar(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const Center(
                              child: Column(
                                children: [
                                  Center(child: CircularProgressIndicator()),
                                ],
                              ),
                            );
                          });
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple.shade400,
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 40.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
