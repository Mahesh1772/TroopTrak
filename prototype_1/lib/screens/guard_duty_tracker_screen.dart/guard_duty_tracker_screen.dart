import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/duty_personnel_data_source.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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

List<DutyPersonnel> dutyPersonnel = <DutyPersonnel>[];

late DutyPersonnelDataSource dutyPersonnelDataSource;

@override
void initState() {
  //super.initState();
  dutyPersonnel = getDutyPersonnel();
  dutyPersonnelDataSource =
      DutyPersonnelDataSource(dutyPersonnel: dutyPersonnel);
}

List<DutyPersonnel> getDutyPersonnel() {
  return [
    DutyPersonnel("Aakash Ramaswamy", '', 'Project Lead', 20000),
    DutyPersonnel("Nikhil Babu", 'Kathryn', 'Manager', 30000),
    DutyPersonnel("Siva Mahesh", 'Lara', 'Developer', 15000),
    DutyPersonnel("Heys", 'Michael', 'Designer', 15000),
  ];
}

class _GuardDutyTrackerScreenState extends State<GuardDutyTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Padding(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.r)),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
