import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/util/duty_personnel_data_source.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/constants.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

class PointsLeaderBoard extends StatefulWidget {
  const PointsLeaderBoard({super.key});

  @override
  State<PointsLeaderBoard> createState() => _PointsLeaderBoardState();
}

class DutyPersonnel {
  DutyPersonnel(this.name, this.image, this.rank, this.points);
  final String name;
  final String image;
  final String rank;
  final double? points;
}

// The list of all document IDs,
//which have access to each their own personal information
List<String> documentIDs = [];

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> userDetails = [];

//Information for column of data
List<DutyPersonnel> dutyPersonnel = <DutyPersonnel>[];

//bool value,
bool isFirstTIme = true;

late DutyPersonnelDataSource dutyPersonnelDataSource;

//All information on Duties
List<Map<dynamic, dynamic>> dutyInfo = [];

//To have a points table
final Map<dynamic, double?> pointsTable = {};

List<DutyPersonnel> getDutyPersonnel() {
  List<DutyPersonnel> array = [];
  if (userDetails.isNotEmpty) {
    for (int i = 0; i < userDetails.length; i += 1) {
      array.add(DutyPersonnel(
          userDetails[i]['name'],
          "lib/assets/army-ranks/solider.png",
          userDetails[i]['rank'],
          pointsTable[userDetails[i]['name']]!));
    }
  }
  return array;
}

class _PointsLeaderBoardState extends State<PointsLeaderBoard> {
  @override
  Widget build(BuildContext context) {
    final userDetailsModel = Provider.of<UserData>(context);
    Future.delayed(const Duration(milliseconds: 5000), () {
      return const CircularProgressIndicator();
    });
    return Container(
      margin: EdgeInsets.only(top: 20.0.h),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(defaultPadding.sp),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54,
                          offset: Offset(10.0.w, 10.0.h),
                          blurRadius: 2.0.r,
                          spreadRadius: 2.0.r),
                    ],
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 72, 30, 229),
                        Color.fromARGB(255, 130, 60, 229),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  ),
                  child: const Icon(Icons.leaderboard_rounded,
                      color: Colors.white),
                ),
                SizedBox(
                  width: 20.w,
                ),
                StyledText("Points Leaderboard", 24.sp,
                    fontWeight: FontWeight.bold),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0.h),
              child: StreamBuilder2<QuerySnapshot, QuerySnapshot>(
                streams: StreamTuple2(
                    userDetailsModel.data, userDetailsModel.conducts_data),
                builder: (context, snapshots) {
                  if (snapshots.snapshot1.hasData) {
                    isFirstTIme = false;
                    documentIDs = [];
                    userDetails = [];
                    //pointsTable = {};
                    var users = snapshots.snapshot1.data?.docs.toList();
                    for (var user in users!) {
                      var data = user.data();
                      userDetails.add(data as Map<String, dynamic>);
                      pointsTable[data['name']] = data['points'].toDouble();
                    }
                    dutyPersonnel = getDutyPersonnel();
                    dutyPersonnelDataSource =
                        DutyPersonnelDataSource(dutyPersonnel: dutyPersonnel);
                    return Padding(
                      padding: EdgeInsets.all(8.0.sp),
                      child: SizedBox(
                        width: double.maxFinite,
                        height: 630.h,
                        child: SfDataGridTheme(
                          data: SfDataGridThemeData(
                              sortIconColor: Colors.white,
                              filterIconColor: Colors.white,
                              headerColor: Colors.deepPurple.shade700),
                          child: SfDataGrid(
                            rowHeight: 100.h,
                            allowSorting: true,
                            allowFiltering: true,
                            source: dutyPersonnelDataSource,
                            columnWidthMode: ColumnWidthMode.fill,
                            columns: <GridColumn>[
                              GridColumn(
                                columnName: 'rank',
                                label: Container(
                                  padding: EdgeInsets.all(8.0.sp),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Rank",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'name',
                                label: Container(
                                  padding: EdgeInsets.all(8.0.sp),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Name",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              GridColumn(
                                columnName: 'points',
                                label: Container(
                                  padding: EdgeInsets.all(8.0.sp),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Points",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return CircularProgressIndicator(
                    color: Colors.deepPurple.shade400,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
