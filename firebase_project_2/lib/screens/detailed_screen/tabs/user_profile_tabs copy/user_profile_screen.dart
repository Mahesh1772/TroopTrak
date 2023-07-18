import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/screens/detailed_screen/qr_screen.dart';
import 'package:firebase_project_2/screens/detailed_screen/tabs/user_profile_tabs%20copy/user_profile_attendance_tab.dart.dart';
import 'package:firebase_project_2/screens/detailed_screen/tabs/user_profile_tabs%20copy/user_profile_basic_info_tab.dart';
import 'package:firebase_project_2/screens/detailed_screen/tabs/user_profile_tabs%20copy/user_profile_statuses_tab.dart';
import 'package:firebase_project_2/screens/detailed_screen/util/custom_rect_tween.dart';
import 'package:firebase_project_2/screens/detailed_screen/util/hero_dialog_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:provider/provider.dart';

import '../../../../user_models/user_details.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  //String fname = FirebaseAuth.instance.currentUser!.displayName.toString();
  final fname = FirebaseAuth.instance.currentUser!.uid.toString();

  Map<String, dynamic> data = {};

  @override
  Widget build(BuildContext context) {
    final userDetailsModel = Provider.of<UserData>(context);
    TabController tabController = TabController(length: 3, vsync: this);

    bool rankColorPicker(String rank) {
      return (rank == 'REC' ||
          rank == 'PTE' ||
          rank == 'LCP' ||
          rank == 'CPL' ||
          rank == 'CFC' ||
          rank == '3SG' ||
          rank == '2SG' ||
          rank == '1SG' ||
          rank == 'SSG' ||
          rank == 'MSG' ||
          rank == '3WO' ||
          rank == '2WO' ||
          rank == '1WO' ||
          rank == 'MWO' ||
          rank == 'SWO' ||
          rank == 'CWO');
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
            stream: userDetailsModel.menData_data(fname),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                data = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 72, 30, 229),
                            Color.fromARGB(255, 130, 60, 229),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 20.0.w,
                                        right: 20.0.w,
                                        top: 20.0.h),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['name'].toUpperCase(),
                                                maxLines: 3,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 25.sp,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              Text(
                                                data['appointment'],
                                                maxLines: 2,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Image.asset(
                                          "lib/assets/army-ranks/${data['rank'].toString().toLowerCase()}.png",
                                          width: 60.w,
                                          color: rankColorPicker(
                                                  data['rank'].toUpperCase())
                                              ? Colors.white
                                              : null,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.0.w),
                                    child: Text(
                                      "${data['company'].toUpperCase()} COMPANY",
                                      maxLines: 2,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 20.0.w, bottom: 20.0.h),
                                    child: Text(
                                      "Platoon ${data['platoon']}, Section ${data['section']}",
                                      maxLines: 2,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            HeroDialogRoute(builder: (context) {
                                          return const GenerateQRScreen();
                                        }));
                                      },
                                      child: Hero(
                                        tag: "QRCodeScreen",
                                        createRectTween: (begin, end) {
                                          return CustomRectTween(
                                              begin: begin!, end: end!);
                                        },
                                        child: Container(
                                          width: 300.w,
                                          padding: EdgeInsets.all(16.sp),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20.r),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.qr_code_2_rounded,
                                                color: Colors.white,
                                                size: 35.sp,
                                              ),
                                              SizedBox(
                                                width: 20.w,
                                              ),
                                              StyledText(
                                                "SHOW QR CODE",
                                                20.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30.h,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        TabBar(
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                          controller: tabController,
                          tabs: const [
                            Tab(
                              text: "BASIC INFO",
                              icon: Icon(
                                Icons.info,
                                color: Colors.white,
                              ),
                            ),
                            Tab(
                              text: "STATUSES",
                              icon: Icon(
                                Icons.warning_rounded,
                                color: Colors.white,
                              ),
                            ),
                            Tab(
                              text: "ATTENDANCE",
                              icon: Icon(
                                Icons.person_add_alt_1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.maxFinite,
                          height: 750.h,
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              //Basic Info tab
                              UserProfileBasicInfoTab(
                                  dateOfBirth: data['dob'],
                                  rationType: data['rationType'],
                                  bloodType: data['bloodgroup'],
                                  enlistmentDate: data['enlistment'],
                                  ordDate: data['ord']),

                              //Statuses tab
                              UserProfileStatusesTab(
                                docID: data['name'],
                              ),

                              UserProfileAttendanceTab(
                                docID: data['name'],
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                );
              }
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: CircularProgressIndicator(
                    color: Colors.deepPurple,
                  )),
                ],
              );
            }),
      ),
    );
  }
}
