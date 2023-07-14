// ignore_for_file: must_be_immutable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/phone_authentication/wrapper.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/screens/dashboard_screen/util/calendar/dashboard_calendar.dart';
import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:firebase_project_2/util/constants.dart';
import 'package:firebase_project_2/screens/dashboard_screen/util/pie_chart/current_strength_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_project_2/screens/dashboard_screen/util/dashboard_soldier_tile.dart';
import 'package:provider/provider.dart';
import '../../phone_authentication/provider/auth_provider.dart';
import '../detailed_screen/tabs/user_profile_tabs copy/user_profile_screen.dart';
import 'package:flip_card/flip_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> userDetails = [];

Map<String, dynamic> currentUserData = {};

//This is what the stream builder is waiting for
late Stream<QuerySnapshot> documentStream;

// The list of all document IDs,
//which have access to each their own personal information
List<String> documentIDs = [];

final FlipCardController _controller = FlipCardController();

class _DashboardScreenState extends State<DashboardScreen> {
  final name = FirebaseAuth.instance.currentUser!.uid.toString();

  String fname = FirebaseAuth.instance.currentUser!.displayName.toString();

  Future getCurrentUserData() async {
    var data = FirebaseFirestore.instance.collection('Men').doc(name);
    data.get().then((DocumentSnapshot doc) {
      currentUserData = doc.data() as Map<String, dynamic>;
      // ...
    });
  }

  void getDocIDs() {
    fname = currentUserData['name'];
  }

  void cardFlipAnimations() {
    _controller.hint(
      duration: const Duration(seconds: 2),
      total: const Duration(seconds: 4),
    );
  }

  @override
  void initState() {
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
    getCurrentUserData();
    //getDocIDs();
    print(currentUserData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final userid = Provider.of<AuthProvider>(context, listen: true).userid;
    print(ap.userid);
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
                        ap.userSignOut().then((value) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Wrapper(),
                            ),
                          );
                        });
                        //FirebaseAuth.instance.signOut();
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
              FlipCard(
                controller: _controller,
                front: Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding.w),
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
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      color: Colors.white.withOpacity(0.45)),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 16.0.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                        const CurrentStrengthBreakdownTile(
                          title: "Total Officers",
                          imgSrc: "lib/assets/icons8-medals-64.png",
                          currentNumOfSoldiers: 6,
                          totalNumOfSoldiers: 9,
                          imgColor: Colors.red,
                        ),
                        const CurrentStrengthBreakdownTile(
                          title: "Total WOSEs",
                          imgSrc: "lib/assets/icons8-soldier-man-64.png",
                          currentNumOfSoldiers: 74,
                          totalNumOfSoldiers: 117,
                          imgColor: Colors.blue,
                        ),
                        const CurrentStrengthBreakdownTile(
                          title: "On Status",
                          imgSrc: "lib/assets/icons8-error-64.png",
                          currentNumOfSoldiers: 25,
                          totalNumOfSoldiers: 126,
                          imgColor: Colors.yellow,
                        ),
                        const CurrentStrengthBreakdownTile(
                          title: "On MA",
                          imgSrc: "lib/assets/icons8-doctors-folder-64.png",
                          currentNumOfSoldiers: 1,
                          totalNumOfSoldiers: 126,
                          imgColor: Colors.lightBlueAccent,
                        ),
                      ],
                    ),
                  ),
                ),
                back: Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding.w),
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
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
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
              ),
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

class CurrentStrengthBreakdownTile extends StatelessWidget {
  const CurrentStrengthBreakdownTile({
    super.key,
    required this.title,
    required this.imgSrc,
    required this.currentNumOfSoldiers,
    required this.totalNumOfSoldiers,
    required this.imgColor,
  });

  final String title, imgSrc;
  final int currentNumOfSoldiers, totalNumOfSoldiers;
  final Color imgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: defaultPadding.h,
      ),
      padding: EdgeInsets.all(defaultPadding.sp),
      decoration: BoxDecoration(
        border: Border.all(width: 2.w, color: Colors.blue.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            SizedBox(
              height: 20.h,
              width: 20.w,
              child: Image.asset(
                imgSrc,
                color: imgColor,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "$currentNumOfSoldiers In Camp",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Text(
              "$currentNumOfSoldiers / $totalNumOfSoldiers",
              style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ],
        ),
        collapsedIconColor: Colors.white,
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: documentStream,
              builder: (context, snapshot) {
                documentIDs = [];
                userDetails = [];
                List? users = snapshot.data?.docs.toList();
                var docsmapshot = snapshot.data!;

                for (var i = 0; i < users!.length; i++) {
                  documentIDs.add(users[i]['name']);
                  var data = docsmapshot.docs[i].data() as Map<String, dynamic>;
                  userDetails.add(data);
                }

                return SizedBox(
                  height: 220.h,
                  child: ListView.builder(
                    itemCount: userDetails.length,
                    padding: EdgeInsets.all(12.sp),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return DashboardSoldierTile(
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
                );
              }),
        ],
      ),
    );
  }
}
