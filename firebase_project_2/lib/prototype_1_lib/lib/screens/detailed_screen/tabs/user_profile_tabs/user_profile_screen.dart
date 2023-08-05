import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/user_profile_tabs/all_tabls/user_profile_basic_info_tab.dart';
import 'package:firebase_project_2/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/user_profile_tabs/all_tabls/user_profile_attendance_tab.dart.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/user_profile_tabs/all_tabls/user_profile_statuses_tab.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../main.dart';
import '../../../../user_models/user_details.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen(
      {required this.docID, super.key, required this.isToggled});
  final String docID;
  final bool isToggled;
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

ThemeManager _themeManager = ThemeManager();
var name = FirebaseAuth.instance.currentUser!.displayName.toString();
Map<String, dynamic> currentUser = {};

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    //name = widget.docID;
    super.initState();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  callback() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.isToggled ? Colors.white : Colors.black;
    _storeOnBoardInfo(int isViewed) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('onBoard', isViewed);
    }

    name = widget.docID;
    //print(widget.docID);
    //print(name);
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

    final statusModel = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: widget.isToggled
          ? const Color.fromARGB(255, 21, 25, 34)
          : const Color.fromARGB(255, 243, 246, 254),
      body: SingleChildScrollView(
        child: StreamBuilder(
            stream: statusModel.userData_data(name),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // List to store all user data, whilst also mapping to name
                currentUser = snapshot.data!.data() as Map<String, dynamic>;
              }
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.arrow_back_sharp,
                                        color: Colors.white,
                                        size: 30.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 20.0.w, right: 20.0.w, top: 20.0.h),
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
                                              currentUser['name'].toUpperCase(),
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
                                              currentUser['appointment'],
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
                                        "lib/assets/army-ranks/${currentUser['rank'].toString().toLowerCase()}.png",
                                        width: 60.w,
                                        color: rankColorPicker(
                                                currentUser['rank']
                                                    .toUpperCase())
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
                                    "${currentUser['company'].toUpperCase()} COMPANY",
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
                                    "Platoon ${currentUser['platoon']}, Section ${currentUser['section']}",
                                    maxLines: 2,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30.h,
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: InkWell(
                              key: const Key("signOutButton"),
                              onTap: () async {
                                //await FirebaseAuth.instance.signOut();
                                //Navigator.pop(context);
                                //.then((value) => Navigator.pop(context));
                                //Navigator.pop(context);
                                await FirebaseAuth.instance
                                    .signOut()
                                    .then((value) async {
                                  _storeOnBoardInfo(2);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MyAppCommander(),
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                width: 300.w,
                                padding: EdgeInsets.all(16.sp),
                                decoration: BoxDecoration(
                                  color: Colors.transparent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.exit_to_app_rounded,
                                      color: Colors.white,
                                      size: 35.sp,
                                    ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    Text("SIGN OUT",
                                        style: GoogleFonts.poppins(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   height: 20.h,
                          // ),
                          // Center(
                          //   child: AnimatedToggleSwitch<bool>.rolling(
                          //     current:
                          //         _themeManager.themeMode == ThemeMode.dark,
                          //     allowUnlistedValues: true,
                          //     values: const [false, true],
                          //     onChanged: (i) {
                          //       _themeManager.toggleTheme(i);
                          //       print(_themeManager.themeMode);
                          //     },
                          //     iconBuilder: rollingIconBuilder,
                          //     borderWidth: 3.0.w,
                          //     indicatorColor: Colors.white,
                          //     innerGradient: LinearGradient(colors: [
                          //       Colors.transparent.withOpacity(0.1),
                          //       Colors.transparent.withOpacity(0),
                          //     ]),
                          //     innerColor: Colors.amber,
                          //     height: 40.h,
                          //     dif: 10.w,
                          //     iconRadius: 10.0.r,
                          //     selectedIconRadius: 13.0.r,
                          //     borderColor: Colors.transparent,
                          //     foregroundBoxShadow: [
                          //       BoxShadow(
                          //         color: Colors.black26,
                          //         spreadRadius: 1.r,
                          //         blurRadius: 2.r,
                          //         offset: Offset(0.w, 1.5.h),
                          //       )
                          //     ],
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: Colors.black26,
                          //         spreadRadius: 1.r,
                          //         blurRadius: 2.r,
                          //         offset: Offset(0.w, 1.5.h),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 30.h,
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
                        indicatorColor: const Color.fromARGB(255, 72, 30, 229),
                        labelColor: textColor,
                        unselectedLabelStyle: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                            color: textColor),
                        labelStyle: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                            color: textColor),
                        controller: tabController,
                        tabs: [
                          Tab(
                            text: "BASIC INFO",
                            icon: Icon(Icons.info, color: textColor),
                          ),
                          Tab(
                            text: "STATUSES",
                            icon: Icon(Icons.warning_rounded, color: textColor),
                          ),
                          Tab(
                            text: "ATTENDANCE",
                            icon:
                                Icon(Icons.person_add_alt_1, color: textColor),
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
                              dateOfBirth:
                                  currentUser['dob'], //widget.dateOfBirth,
                              rationType: currentUser[
                                  'rationType'], //widget.rationType,
                              bloodType:
                                  currentUser['bloodgroup'], //widget.bloodType,
                              enlistmentDate: currentUser[
                                  'enlistment'], //widget.enlistmentDate,
                              docID: name,
                              ordDate: currentUser['ord'],
                              callback: callback,
                              isToggled: widget.isToggled,
                            ), //widget.ordDate),

                            //Statuses tab
                            UserProfileStatusesTab(
                              isToggled: widget.isToggled,
                            ),

                            UserProfileAttendanceTab(
                                isToggled: widget.isToggled),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              );
            }),
      ),
    );
  }
}

Widget rollingIconBuilder(bool value, Size iconSize, bool foreground) {
  IconData data;

  if (value) {
    data = Icons.dark_mode_rounded;
  } else {
    data = Icons.light_mode_rounded;
  }
  return Icon(
    data,
    size: iconSize.shortestSide,
  );
}
