// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/org_chart_tile.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';

class AddNewDutyScreen extends StatefulWidget {
  AddNewDutyScreen({
    super.key,
    required this.dutyDate,
    required this.dutyStartTime,
    required this.dutyEndTime,
  });

  late String dutyDate;
  late String dutyStartTime;
  late String dutyEndTime;

  @override
  State<AddNewDutyScreen> createState() => _AddNewDutyScreenState();
}

List<List<String>> dutySoldiersAndRanks = [];

class _AddNewDutyScreenState extends State<AddNewDutyScreen> {
  double points = 0;
  late String typeOfDay;

  @override
  void initState() {
    pointsAssignment(DateTime.now());
    populateHeroTagArray();
    super.initState();
  }

  void pointsAssignment(DateTime value) {
    if (widget.dutyDate != "Date of Duty:") {
      int nowDay = value.weekday;

      if (nowDay < 5) {
        points = 1;
        typeOfDay = "Weekday Duty 🫣";
      } else if (nowDay == 5) {
        points = 1.5;
        typeOfDay = "Weekday (Friday) Duty 😖";
      } else if (nowDay == 6) {
        points = 2.5;
        typeOfDay = "Weekend (Saturday) Duty 😵‍💫";
      } else if (nowDay == 7) {
        points = 2;
        typeOfDay = "Weekday (Sunday) Duty 🤧";
      }
    } else {
      points = 0;
      typeOfDay = "Select a duty date! 😄";
    }
  }

  void _showStartDatePicker() {
    var initialDate;
    if (widget.dutyDate == "Date of Duty:") {
      initialDate = DateTime.now();
    } else {
      initialDate = DateFormat("d MMM yyyy").parse(widget.dutyDate);
    }
    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          pointsAssignment(value);

          widget.dutyDate = DateFormat('d MMM yyyy').format(value);
        }
      });
    });
  }

  void _showStartTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then(
      ((value) {
        setState(
          () {
            if (value != null) {
              widget.dutyStartTime = value.format(context).toString();
            }
          },
        );
      }),
    );
  }

  void _showEndTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then(
      ((value) {
        setState(
          () {
            if (value != null) {
              widget.dutyEndTime = value.format(context).toString();
            }
          },
        );
      }),
    );
  }

  List<String> heroAddDutySoldiers = [];

  void populateHeroTagArray() {
    for (var i = 0; i < 10; i++) {
      heroAddDutySoldiers.add('add-duty-soldiers-hero-$i');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dutyDate != "Date of Duty:") {
      pointsAssignment(DateFormat("d MMM yyyy").parse(widget.dutyDate));
    }
    final _formKey = GlobalKey<FormState>();
    final _formKey1 = GlobalKey<FormState>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                StyledText("Who is performing this duty?", 26.sp,
                    fontWeight: FontWeight.bold),
                StyledText("Add details of the guard duty.", 16.sp,
                    fontWeight: FontWeight.w400),
                SizedBox(
                  height: 30.h,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OrgChartTile(
                        rank: "3SG",
                        name: "Aakash Ramaswamy",
                        heroTag: heroAddDutySoldiers[0],
                      ),
                      OrgChartTile(
                        rank: "2SG",
                        name: "Sivagnanam Maheshwaran",
                        heroTag: heroAddDutySoldiers[1],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OrgChartTile(
                      rank: "LCP",
                      name: "Aakash Ramaswamy",
                      heroTag: heroAddDutySoldiers[2],
                    ),
                    OrgChartTile(
                      rank: "LCP",
                      name: "John Doe",
                      heroTag: heroAddDutySoldiers[3],
                    ),
                    OrgChartTile(
                      rank: "CPL",
                      name: "Aakash Ramaswamy",
                      heroTag: heroAddDutySoldiers[4],
                    ),
                    OrgChartTile(
                      rank: "PTE",
                      name: "John Doe",
                      heroTag: heroAddDutySoldiers[5],
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OrgChartTile(
                      rank: "LCP",
                      name: "Aakash Ramaswamy",
                      heroTag: heroAddDutySoldiers[6],
                    ),
                    OrgChartTile(
                      rank: "LCP",
                      name: "John Doe",
                      heroTag: heroAddDutySoldiers[7],
                    ),
                    OrgChartTile(
                      rank: "CPL",
                      name: "Aakash Ramaswamy",
                      heroTag: heroAddDutySoldiers[8],
                    ),
                    OrgChartTile(
                      rank: "PTE",
                      name: "John Doe",
                      heroTag: heroAddDutySoldiers[9],
                    ),
                  ],
                ),
                SizedBox(
                  height: 50.h,
                ),
                GestureDetector(
                  onTap: () {},
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(16.0.sp),
                    width: double.maxFinite,
                    height: 215.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 72, 30, 229),
                          Color.fromARGB(255, 130, 60, 229),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 130, 60, 229)
                              .withOpacity(0.6),
                          spreadRadius: 1.r,
                          blurRadius: 16.r,
                          offset: Offset(8.w, 0.h),
                        ),
                        BoxShadow(
                          color: const Color.fromARGB(255, 72, 30, 229)
                              .withOpacity(0.2),
                          spreadRadius: 8.r,
                          blurRadius: 8.r,
                          offset: Offset(-8.w, 0.h),
                        ),
                        BoxShadow(
                          color: const Color.fromARGB(255, 130, 60, 229)
                              .withOpacity(0.2),
                          spreadRadius: 8.r,
                          blurRadius: 8.r,
                          offset: Offset(8.w, 0.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText("EXPECTED POINTS PER PERSON", 14.sp,
                            fontWeight: FontWeight.w400),
                        SizedBox(
                          height: 15.h,
                        ),
                        StyledText(typeOfDay, 24.sp,
                            fontWeight: FontWeight.w500),
                        SizedBox(
                          height: 10.h,
                        ),
                        StyledText("${points.toString()} Points", 32.sp,
                            fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50.h,
                ),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          _showStartDatePicker();
                        },
                        child: Container(
                          height: 70.h,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 15.h),
                                child: AutoSizeText(
                                  widget.dutyDate,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 16.sp),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0.sp),
                                child: const Icon(
                                  Icons.date_range_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              _showStartTimePicker();
                            },
                            child: Container(
                              height: 70.h,
                              width: 200.w,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w, vertical: 15.h),
                                    child: AutoSizeText(
                                      widget.dutyStartTime,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 16.sp),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0.sp),
                                    child: const Icon(
                                      Icons.access_time_filled_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          InkWell(
                            onTap: () {
                              _showEndTimePicker();
                            },
                            child: Container(
                              height: 70.h,
                              width: 200.w,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w, vertical: 15.h),
                                    child: AutoSizeText(
                                      widget.dutyEndTime,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white, fontSize: 16.sp),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0.sp),
                                    child: const Icon(
                                      Icons.access_time_filled_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState!.validate() &&
                        _formKey1.currentState!.validate() &&
                        widget.dutyEndTime != "End Time:" &&
                        widget.dutyStartTime != "Start Time:" &&
                        widget.dutyDate != "Date of Duty:") {
                      IconSnackBar.show(
                          duration: const Duration(seconds: 1),
                          direction: DismissDirection.horizontal,
                          context: context,
                          snackBarType: SnackBarType.save,
                          label: 'Conduct added successfully!',
                          snackBarStyle: const SnackBarStyle() // this one
                          );
                    } else {
                      IconSnackBar.show(
                          direction: DismissDirection.horizontal,
                          context: context,
                          snackBarType: SnackBarType.alert,
                          label: 'Details missing',
                          snackBarStyle: const SnackBarStyle() // this one
                          );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_moderator_rounded,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          AutoSizeText(
                            'ADD GUARD DUTY',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.sp,
                            ),
                          ),
                        ],
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
        ),
      ),
    );
  }
}
