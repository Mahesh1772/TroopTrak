import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/add_new_duty_screen.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/duty_personnel_data_source.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class GuardDutyTrackerScreen extends StatefulWidget {
  const GuardDutyTrackerScreen({super.key});

  @override
  State<GuardDutyTrackerScreen> createState() => _GuardDutyTrackerScreenState();
}

class DutyPersonnel {
  DutyPersonnel(this.name, this.image, this.rank, this.points);
  final String name;
  final String image;
  final String rank;
  final int points;
}

//This is what the stream builder is waiting for
late Stream<QuerySnapshot> documentStream;

// The list of all document IDs,
//which have access to each their own personal information
List<String> documentIDs = [];

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> userDetails = [];

List<DutyPersonnel> dutyPersonnel = <DutyPersonnel>[];

late DutyPersonnelDataSource dutyPersonnelDataSource;

List<DutyPersonnel> getDutyPersonnel() {
  List<DutyPersonnel> array = [];
  for (int i = 0; i < userDetails.length; i += 1) {
    array.add(DutyPersonnel(userDetails[i]['name'],
        "lib/assets/army-ranks/solider.png", userDetails[i]['rank'], i));
  }

  return array;
}

class _GuardDutyTrackerScreenState extends State<GuardDutyTrackerScreen> {
  @override
  void initState() {
    super.initState();
    dutyPersonnel = getDutyPersonnel();
    dutyPersonnelDataSource =
        DutyPersonnelDataSource(dutyPersonnel: dutyPersonnel);
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> upcomingDuties = [
      {
        'dutyDate': '9 Mar 2023',
        'startTime': '08:00',
        'endTime': '07:30 (Next day)'
      },
      {
        'dutyDate': '12 Mar 2023',
        'startTime': '08:00',
        'endTime': '07:30 (Next day)'
      }
    ];
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
                    onTap: () {},
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
                height: 20.h,
              ),
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
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: documentStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      documentIDs = [];
                      userDetails = [];
                      var users = snapshot.data?.docs.toList();

                      for (var user in users!) {
                        var data = user.data();
                        userDetails.add(data as Map<String, dynamic>);
                      }
                      dutyPersonnel = getDutyPersonnel();
                      dutyPersonnelDataSource =
                          DutyPersonnelDataSource(dutyPersonnel: dutyPersonnel);
                    }
                    return Padding(
                      padding: EdgeInsets.all(8.0.sp),
                      child: SizedBox(
                        width: double.maxFinite,
                        height: 500,
                        child: SfDataGridTheme(
                          data: SfDataGridThemeData(
                              sortIconColor: Colors.white,
                              filterIconColor: Colors.white,
                              headerColor: Colors.deepPurple.shade700),
                          child: SfDataGrid(
                            rowHeight: 100,
                            allowSorting: true,
                            //allowFiltering: true,
                            source: dutyPersonnelDataSource,
                            columnWidthMode: ColumnWidthMode.fill,
                            columns: <GridColumn>[
                              GridColumn(
                                columnName: 'rank',
                                label: Container(
                                  padding: EdgeInsets.all(16.0.sp),
                                  alignment: Alignment.center,
                                  child: StyledText("Rank", 20.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              GridColumn(
                                columnName: 'name',
                                label: Container(
                                  padding: EdgeInsets.all(16.0.sp),
                                  alignment: Alignment.center,
                                  child: StyledText("Name", 20.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              GridColumn(
                                columnName: 'points',
                                label: Container(
                                  padding: EdgeInsets.all(16.0.sp),
                                  alignment: Alignment.center,
                                  child: StyledText("Points", 20.sp,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                child: StyledText("Upcoming Duties", 24.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 10.h,
              ),
              SfCalendar(
                view: CalendarView.schedule,
              ),
              SizedBox(
                height: 30.h,
              )
            ],
          ),
        ),
      ),
    );
  }
}
