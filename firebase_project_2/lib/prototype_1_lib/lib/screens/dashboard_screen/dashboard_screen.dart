// ignore_for_file: must_be_immutable
import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/dashboard_screen/util/calendar/dashboard_calendar.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/dashboard_screen/util/current_strength_breakdown_tile.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/constants.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/dashboard_screen/util/pie_chart/current_strength_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';
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

int spec_list_length = 0;
int officer_list_length = 0;

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

final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);

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

  String name = FirebaseAuth.instance.currentUser!.displayName.toString();

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.background;
    statusList = [];
    _maList = [];
    List<Map<String, dynamic>> _maDetails = [];
    List<Map<String, dynamic>> statusDetails = [];
    Map<String, dynamic> fullList = {};

    List<Map<String, dynamic>> inCamp(
        List<Map<String, dynamic>> userDetails, bool isStatusPersonal) {
      List<Map<String, dynamic>> insideCamp = [];

      if (isStatusPersonal) {
        return userDetails;
      }

      for (var user in userDetails) {
        if (fullList[user['name']]) {
          insideCamp.add(user);
        }
      }
      return insideCamp;
    }

    final statusModel = Provider.of<UserData>(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          child: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
                stream: statusModel.data,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    userDetails = [];
                    officerDetails = [];
                    specDetails = [];
                    fullList = {};
                    counter = 0;
// Create a Completer to delay the execution until we have collected data from all 'Statuses' subcollections

                    StreamController<void> controller =
                        StreamController<void>();
                    List? users = snapshot.data?.docs.toList();
                    var docsmapshot = snapshot.data!;
                    for (var i = 0; i < users!.length; i++) {
                      final uid = users[i]['name'];
                      counter++;
                      var data =
                          docsmapshot.docs[i].data() as Map<String, dynamic>;
                      userDetails.add(data);
                      userDetails[i]
                          .addEntries({'ID': users[i].reference.id}.entries);
                      if (specialist.contains(data['rank'])) {
                        specDetails.add(data);
                      } else if (officers.contains(data['rank'])) {
                        officerDetails.add(data);
                      }
                      if (userDetails[i]['ID'] == name) {
                        name = userDetails[i]['name'];
                      }
                      bool val =
                          data['currentAttendance'] == 'Outside' ? false : true;
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
                            DateTime start = DateFormat("d MMM yyyy")
                                .parse(statusData['startDate']);
                            if (DateTime(end.year, end.month, end.day + 1)
                                    .isAfter(DateTime.now()) &&
                                today ==
                                    DateTime(
                                        start.year, start.month, start.day)) {
                              if (statusData['statusType'] ==
                                  'Medical Appointment') {
                                _maDetails.add(Map<String, dynamic>.from(data));
                              } else {
                                statusDetails
                                    .add(Map<String, dynamic>.from(data));
                              }
                            }
                          });
                          if (counter == users.length) {
                            controller.add(null);
                          }
                        }
                      });
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        StreamBuilder<void>(
                          stream: controller.stream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              statusDetails =
                                  LinkedHashSet<Map<String, dynamic>>.from(
                                          statusDetails)
                                      .toList();
                              _maDetails =
                                  LinkedHashSet<Map<String, dynamic>>.from(
                                          _maDetails)
                                      .toList();

                              return FlipCard(
                                controller: _controller,
                                front: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: defaultPadding.w),
                                  child: Container(
                                    padding: EdgeInsets.all(defaultPadding.sp),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54,
                                            offset: Offset(10.0.w, 10.0.h),
                                            blurRadius: 2.0.r,
                                            spreadRadius: 2.0.r),
                                      ],
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "As of ${DateFormat('yMMMMd').add_Hm().format(DateTime.now())}",
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color!
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
                                                      _controller.toggleCard();
                                                    },
                                                    child: Icon(
                                                      Icons.date_range_rounded,
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
                                              inCamp(officerDetails, false)
                                                  .length,
                                          currentWOSEs:
                                              inCamp(specDetails, false).length,
                                          currentStatus:
                                              inCamp(statusDetails, true)
                                                  .length,
                                          currentMA:
                                              inCamp(_maDetails, true).length,
                                          totalOfficers: officerDetails.length,
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
                                              inCamp(officerDetails, false)
                                                  .length,
                                          totalNumOfSoldiers:
                                              officerDetails.length,
                                          imgColor: Colors.red,
                                          userDetails:
                                              inCamp(officerDetails, false),
                                          fullList: fullList,
                                          isToggled: (backgroundColor ==
                                                  const Color.fromARGB(
                                                      255, 243, 246, 254))
                                              ? false
                                              : true,
                                        ),
                                        CurrentStrengthBreakdownTile(
                                          title: "Total WOSEs",
                                          imgSrc:
                                              "lib/assets/icons8-soldier-man-64.png",
                                          currentNumOfSoldiers:
                                              inCamp(specDetails, false).length,
                                          totalNumOfSoldiers:
                                              specDetails.length,
                                          imgColor: Colors.blue,
                                          userDetails:
                                              inCamp(specDetails, false),
                                          fullList: fullList,
                                          isToggled: (backgroundColor ==
                                                  const Color.fromARGB(
                                                      255, 243, 246, 254))
                                              ? false
                                              : true,
                                        ),
                                        CurrentStrengthBreakdownTile(
                                          title: "On Status",
                                          imgSrc:
                                              "lib/assets/icons8-error-64.png",
                                          currentNumOfSoldiers:
                                              statusDetails.length,
                                          totalNumOfSoldiers:
                                              (officerDetails.length +
                                                  specDetails.length),
                                          imgColor: Colors.yellow,
                                          userDetails: statusDetails,
                                          fullList: fullList,
                                          isToggled: (backgroundColor ==
                                                  const Color.fromARGB(
                                                      255, 243, 246, 254))
                                              ? false
                                              : true,
                                        ),
                                        CurrentStrengthBreakdownTile(
                                          title: "On MA",
                                          imgSrc:
                                              "lib/assets/icons8-doctors-folder-64.png",
                                          currentNumOfSoldiers:
                                              _maDetails.length,
                                          totalNumOfSoldiers:
                                              (officerDetails.length +
                                                  specDetails.length),
                                          imgColor: Colors.lightBlueAccent,
                                          userDetails: _maDetails,
                                          fullList: fullList,
                                          isToggled: (backgroundColor ==
                                                  const Color.fromARGB(
                                                      255, 243, 246, 254))
                                              ? false
                                              : true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                back: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: defaultPadding.w),
                                  child: Container(
                                    padding: EdgeInsets.all(defaultPadding.sp),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54,
                                            offset: Offset(10.0.w, 10.0.h),
                                            blurRadius: 2.0.r,
                                            spreadRadius: 2.0.r),
                                      ],
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
                          },
                        ),
                      ],
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepPurple.shade400,
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
