import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/attendance_screen/attendance_tab_detailed_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/basic_info_screen/basic_info_detailed_screen_tab.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/statuses_screen/statuses_detailed_screen_tab.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import '../../user_models/user_details.dart';

class SoldierDetailedScreen extends StatefulWidget {
  const SoldierDetailedScreen({
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
    required this.docID,
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
  final String docID;

  @override
  State<SoldierDetailedScreen> createState() => _SoldierDetailedScreenState();
}

class _SoldierDetailedScreenState extends State<SoldierDetailedScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final soldierModel = Provider.of<UserData>(context);
    TabController tabController = TabController(length: 3, vsync: this);
    Stream docStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.docID)
        .snapshots();

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
        child: StreamBuilder(
            stream: docStream, //soldierModel.userData_data(widget.docID),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> currentUser =
                    snapshot.data!.data() as Map<String, dynamic>;
                currentUser['name'] = widget.soldierName;
                currentUser['rank'] = widget.soldierRank;
                currentUser['appointment'] = widget.soldierAppointment;
                currentUser['section'] = widget.section;
                currentUser['company'] = widget.company;
                currentUser['platoon'] = widget.platoon;
                currentUser['rationType'] = widget.rationType;
                currentUser['bloodgroup'] = widget.bloodType;
                currentUser['ord'] = widget.ordDate;
                currentUser['dob'] = widget.dateOfBirth;
                currentUser['enlistment'] = widget.enlistmentDate;
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                              widget
                                                  .soldierAppointment.titleCase,
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
                                        "lib/assets/army-ranks/${widget.soldierRank.toString().toLowerCase()}.png",
                                        width: 60.w,
                                        color:
                                            rankColorPicker(widget.soldierRank)
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
                                  padding: EdgeInsets.only(
                                      left: 20.0.w, bottom: 50.0.h),
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
                            BasicInfoTab(
                              docID: widget.docID,
                            ),

                            //Statuses tab
                            StatusesTab(
                              docID: widget.docID,
                            ),

                            AttendanceTab(
                              docID: widget.docID,
                            ),
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
