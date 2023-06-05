import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/tabs/user_profile_tabs/user_profile_basic_info_tab.dart';
import 'package:prototype_1/screens/tabs/user_profile_tabs/user_profile_statuses_tab.dart';
import 'package:recase/recase.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    required this.soldierName,
    required this.soldierRank,
    required this.company,
    required this.platoon,
    required this.section,
    required this.soldierAppointment,
    required this.dateOfBirth,
    required this.rationType,
    required this.bloodType,
    required this.enlistmentDate,
    required this.ordDate,
  });

  final String soldierName;
  final String soldierRank;
  final String company;
  final String platoon;
  final String section;
  final String soldierAppointment;
  final String dateOfBirth;
  final String rationType;
  final String bloodType;
  final String enlistmentDate;
  final String ordDate;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: Column(
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
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back_sharp,
                              color: Colors.white,
                              size: 25.sp,
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20.0.w, right: 20.0.w, top: 20.0.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.soldierName.toUpperCase(),
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
                                        widget.soldierAppointment.titleCase,
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
                                  widget.soldierRank,
                                  width: 60.w,
                                  color: Colors.white,
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
                              "${widget.company.toUpperCase()} COMPANY",
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
                            padding:
                                EdgeInsets.only(left: 20.0.w, bottom: 50.0.h),
                            child: Text(
                              "Platoon ${widget.platoon}, Section ${widget.section}",
                              maxLines: 2,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
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
                    fontSize: 16.sp,
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
                  ],
                ),
                SizedBox(
                  width: double.maxFinite,
                  height: 650.h,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      //Basic Info tab
                      UserProfileBasicInfoTab(
                          dateOfBirth: widget.dateOfBirth,
                          rationType: widget.rationType,
                          bloodType: widget.bloodType,
                          enlistmentDate: widget.enlistmentDate,
                          ordDate: widget.ordDate),

                      //Statuses tab
                      UserProfileStatusesTab(docID: widget.soldierName),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
