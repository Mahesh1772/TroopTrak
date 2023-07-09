// ignore_for_file: must_be_immutable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/dashboard_screen/util/calendar/dashboard_calendar.dart';
import 'package:prototype_1/screens/dashboard_screen/util/current_strength_breakdown_tile.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:prototype_1/screens/dashboard_screen/util/pie_chart/current_strength_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../user_models/user_details.dart';
import '../detailed_screen/tabs/user_profile_tabs/user_profile_screen.dart';
import 'package:flip_card/flip_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
List<Map<String, dynamic>> statusDetails = [];

Map<String, dynamic> currentUserData = {};

// All this was supposed to be in another file
List statusList = [];
// All this was supposed to be in another file
List _maList = [];
int i = 0;

//This is what the stream builder is waiting for
late Stream<QuerySnapshot> documentStream;

// The list of all document IDs,
//which have access to each their own personal information
List<String> documentIDs = [];

final FlipCardController _controller = FlipCardController();

class _DashboardScreenState extends State<DashboardScreen> {
  Future getStatusList() async {
    FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(snapshot.id)
            .collection("Statuses")
            .get()
            .then((querySnapshot) {
          for (var result in querySnapshot.docs) {
            Map<String, dynamic> data = result.data();
            DateTime end = DateFormat("d MMM yyyy").parse(data['endDate']);
            if (DateTime(end.year, end.month, end.day + 1)
                .isAfter(DateTime.now())) {
              if (data['statusType'] == 'Medical Appointment') {
                _maList.add(snapshot.id);
              } else {
                statusList.add(snapshot.id);
              }
              //statusList[i].addEntries({'Name': snapshot.id}.entries);
              //i++;
            }
          }
        });
      }
    });
  }

  final name = FirebaseAuth.instance.currentUser!.displayName.toString();

  String fname = FirebaseAuth.instance.currentUser!.displayName.toString();

  Future getCurrentUserData() async {
    var data = FirebaseFirestore.instance.collection('Users').doc(name);
    data.get().then((DocumentSnapshot doc) {
      currentUserData = doc.data() as Map<String, dynamic>;
      // ...
    });
  }

  void cardFlipAnimations() {
    _controller.hint(
      duration: const Duration(seconds: 2),
      total: const Duration(seconds: 4),
    );
  }

  List<String> specialist = [
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

  @override
  void initState() {
    getCurrentUserData();
    getStatusList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final statusModel = Provider.of<UserData>(context);
    return Scaffold(
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
                  Padding(
                    padding: EdgeInsets.only(left: 100.0.w),
                    child: InkWell(
                      onTap: () {
                        //print(fname);
                        FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black54,
                                offset: Offset(10.0.w, 10.0.h),
                                blurRadius: 2.0.r,
                                spreadRadius: 2.0.r),
                          ],
                          color: Colors.deepPurple.shade400,
                          borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(defaultPadding.sp),
                          child: Icon(
                            Icons.exit_to_app_rounded,
                            color: Colors.white,
                            size: 35.sp,
                          ),
                        ),
                      ),
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
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: StyledText(
                  'Welcome,\n$fname! 👋',
                  32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: statusModel.data,
                  builder: (context, snapshot) {
                    documentIDs = [];
                    userDetails = [];
                    List? users = snapshot.data?.docs.toList();
                    var docsmapshot = snapshot.data!;

                    for (var i = 0; i < users!.length; i++) {
                      documentIDs.add(users[i]['name']);
                      var data =
                          docsmapshot.docs[i].data() as Map<String, dynamic>;
                      userDetails.add(data);
                    }

                    specDetails = userDetails
                        .where(
                            (element) => specialist.contains(element['rank']))
                        .toList();

                    statusDetails = userDetails
                        .where(
                            (element) => statusList.contains(element['name']))
                        .toList();

                    print(statusDetails);

                    officerDetails = userDetails
                        .where((element) => officers.contains(element['rank']))
                        .toList();

                    var _maDetails = userDetails
                        .where(
                            (element) => _maList.contains(element['name']))
                        .toList();

                    return FlipCard(
                      controller: _controller,
                      front: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: defaultPadding.w),
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
                            color: const Color.fromARGB(255, 32, 36, 51),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.r)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                            color: Colors.white),
                                      ),
                                      Text(
                                        "As of ${DateFormat('yMMMMd').add_Hm().format(DateTime.now())}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Colors.white.withOpacity(0.45)),
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
                                            color: Colors.white,
                                            size: 30.sp,
                                          ),
                                        ),
                                        StyledText("Show Calendar", 14.sp,
                                            fontWeight: FontWeight.w400),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: (defaultPadding + 2).h,
                              ),
                              CurrentStrengthChart(),
                              SizedBox(
                                height: defaultPadding.h,
                              ),
                              CurrentStrengthBreakdownTile(
                                title: "Total Officers",
                                imgSrc: "lib/assets/icons8-medals-64.png",
                                currentNumOfSoldiers: officerDetails.length,
                                totalNumOfSoldiers: officerDetails.length,
                                imgColor: Colors.red,
                                userDetails: officerDetails,
                              ),
                              CurrentStrengthBreakdownTile(
                                title: "Total WOSEs",
                                imgSrc: "lib/assets/icons8-soldier-man-64.png",
                                currentNumOfSoldiers: specDetails.length,
                                totalNumOfSoldiers: specDetails.length,
                                imgColor: Colors.blue,
                                userDetails: specDetails,
                              ),
                              CurrentStrengthBreakdownTile(
                                title: "On Status",
                                imgSrc: "lib/assets/icons8-error-64.png",
                                currentNumOfSoldiers: 25,
                                totalNumOfSoldiers: statusDetails.length,
                                imgColor: Colors.yellow,
                                userDetails: statusDetails,
                              ),
                              CurrentStrengthBreakdownTile(
                                title: "On MA",
                                imgSrc:
                                    "lib/assets/icons8-doctors-folder-64.png",
                                currentNumOfSoldiers: 1,
                                totalNumOfSoldiers: 126,
                                imgColor: Colors.lightBlueAccent,
                                userDetails: _maDetails,
                              ),
                            ],
                          ),
                        ),
                      ),
                      back: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: defaultPadding.w),
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
                            color: const Color.fromARGB(255, 32, 36, 51),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.r)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              DashboardCalendar(),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              SizedBox(
                height: 40.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}
