// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/util/org_chart_tile.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';

class UpdateDutyScreen extends StatefulWidget {
  UpdateDutyScreen({
    super.key,
    required this.dutyDate,
    required this.dutyStartTime,
    required this.dutyEndTime,
    required this.docID,
    required this.participants,
    required this.numberOfPoints,
  });

  late String dutyDate;
  late String dutyStartTime;
  late String dutyEndTime;
  final String docID;
  final Map<String, dynamic> participants;
  late double numberOfPoints;

  @override
  State<UpdateDutyScreen> createState() => _UpdateDutyScreenState();
}

Map<String, dynamic> dutySoldiersAndRanks = {};

List<String> heroAddDutySoldiers = [];

List<Map<String, dynamic>> listOfPersonal = [];

List documentIDs = [];

double pointsBefore = 0;

class _UpdateDutyScreenState extends State<UpdateDutyScreen> {
  List<String> non_participants = [];

  List<Map<String, dynamic>> statusList = [];

  List<String> guardDuty = ['Ex Uniform', 'Ex Boots'];

  void autoFilter() {
    //non_participants = [];
    print(statusList);
    for (var status in statusList) {
      if (status['statusType'] == 'Excuse') {
        if (guardDuty.contains(status['statusName'])) {
          non_participants.add(status['Name']);
        }
      } else if (status['statusType'] == 'Leave') {
        non_participants.add(status['Name']);
      }
    }
  }

  int i = 0;

  Future getUserBooks() async {
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
              statusList.add(data);
              statusList[i].addEntries({'Name': snapshot.id}.entries);
              i++;
            }
          }
        });
      }
    });
  }

  Future getListOfUsers() async {
    FirebaseFirestore.instance
        .collection("Users")
        .get()
        .then((querySnapshot) async {
      for (var snapshot in querySnapshot.docs) {
        Map<String, dynamic> data = snapshot.data();
        listOfPersonal.add(data);
      }
    });
  }

  void populateDutySoldiersAndRanksArray() {
    dutySoldiersAndRanks = widget.participants;

    var length = dutySoldiersAndRanks.length;

    for (var i = length; i < 10; i++) {
      dutySoldiersAndRanks.addEntries({'NA$i': 'NA'}.entries);
    }
    print(dutySoldiersAndRanks);
  }

  double points = 0;
  late String typeOfDay;

  Future getDocIDs() async {
    FirebaseFirestore.instance
        .collection('Users')
        .get()
        .then((value) => value.docs.forEach((element) {
              documentIDs.add(element['name']);
            }));
  }

  Future addGaurdDuty() async {
    dutySoldiersAndRanks.removeWhere((key, value) => (key.contains("NA")));

    print(dutySoldiersAndRanks);

    await FirebaseFirestore.instance
        .collection('Duties')
        .doc(widget.docID)
        .set({
      //User map formatting
      'points': points,
      'dayType': typeOfDay,
      'dutyDate': widget.dutyDate,
      'startTime': widget.dutyStartTime,
      'endTime': widget.dutyEndTime,
      'participants': dutySoldiersAndRanks
    });

    addPoints();
    print(pointsBefore);
    print(points);
  }

  Future addFieldDetails(String name) async {
    double currentPoints = 0;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(name)
        .get()
        .then((value) {
      var data = value.data();
      currentPoints = data!['points'].toDouble();
    });
    await FirebaseFirestore.instance.collection('Users').doc(name).set({
      //User map formatting
      'points': currentPoints + points - widget.numberOfPoints,
    }, SetOptions(merge: true));
  }

  Future addPoints() async {
    dutySoldiersAndRanks.removeWhere((key, value) => (key.contains("NA")));
    for (var soldier in dutySoldiersAndRanks.keys) {
      addFieldDetails(soldier);
    }
  }

  @override
  void initState() {
    getDocIDs();
    getListOfUsers();
    pointsAssignment(DateTime.now());
    populateHeroTagArray();
    populateDutySoldiersAndRanksArray();
    pointsBefore = points;
    super.initState();
  }

  callBack(finalArray) {
    setState(() {
      dutySoldiersAndRanks = finalArray;
    });
  }

  @override
  void dispose() {
    dutySoldiersAndRanks.clear();
    super.dispose();
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
    DateTime initialDate;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: (Theme.of(context).colorScheme.background ==
                    const Color.fromARGB(255, 243, 246, 254))
                ? ColorScheme.highContrastLight(
                    primary:
                        const Color.fromARGB(255, 129, 71, 230), // <-- SEE HERE
                    onPrimary: Colors.white, // <-- SEE HERE
                    onSurface:
                        Theme.of(context).colorScheme.tertiary, // <-- SEE HERE
                  )
                : ColorScheme.highContrastDark(
                    primary:
                        const Color.fromARGB(255, 129, 71, 230), // <-- SEE HERE
                    onPrimary: Colors.white, // <-- SEE HERE
                    onSurface:
                        Theme.of(context).colorScheme.tertiary, // <-- SEE HERE
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.tertiary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: (Theme.of(context).colorScheme.background ==
                      const Color.fromARGB(255, 243, 246, 254))
                  ? ColorScheme.highContrastLight(
                      primary: const Color.fromARGB(
                          255, 129, 71, 230), // <-- SEE HERE
                      onPrimary: Colors.white, // <-- SEE HERE
                      onSurface: Theme.of(context)
                          .colorScheme
                          .tertiary, // <-- SEE HERE
                    )
                  : ColorScheme.highContrastDark(
                      primary: const Color.fromARGB(
                          255, 129, 71, 230), // <-- SEE HERE
                      onPrimary: Colors.white, // <-- SEE HERE
                      onSurface: Theme.of(context)
                          .colorScheme
                          .tertiary, // <-- SEE HERE
                    ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .tertiary, // button text color
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    ).then(
      ((value) {
        setState(
          () {
            if (value != null) {
              DateTime now = DateTime.now();
              DateTime dt = DateTime(
                  now.year, now.month, now.day, value.hour, value.minute);

              widget.dutyStartTime = DateFormat.jm().format(dt);
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
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: (Theme.of(context).colorScheme.background ==
                      const Color.fromARGB(255, 243, 246, 254))
                  ? ColorScheme.highContrastLight(
                      primary: const Color.fromARGB(
                          255, 129, 71, 230), // <-- SEE HERE
                      onPrimary: Colors.white, // <-- SEE HERE
                      onSurface: Theme.of(context)
                          .colorScheme
                          .tertiary, // <-- SEE HERE
                    )
                  : ColorScheme.highContrastDark(
                      primary: const Color.fromARGB(
                          255, 129, 71, 230), // <-- SEE HERE
                      onPrimary: Colors.white, // <-- SEE HERE
                      onSurface: Theme.of(context)
                          .colorScheme
                          .tertiary, // <-- SEE HERE
                    ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .tertiary, // button text color
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    ).then(
      ((value) {
        setState(
          () {
            if (value != null) {
              DateTime now = DateTime.now();
              DateTime dt = DateTime(
                  now.year, now.month, now.day, value.hour, value.minute);

              widget.dutyEndTime = DateFormat.jm().format(dt);
            }
          },
        );
      }),
    );
  }

  void populateHeroTagArray() {
    for (var i = 0; i < 10; i++) {
      heroAddDutySoldiers.add('add-duty-soldiers-hero-$i');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(dutySoldiersAndRanks);
    if (widget.dutyDate != "Date of Duty:") {
      pointsAssignment(DateFormat("d MMM yyyy").parse(widget.dutyDate));
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
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
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 25.sp,
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                StyledText("Edit an existing duty.", 26.sp,
                    fontWeight: FontWeight.bold),
                StyledText("Fill in the details of the guard duty.", 16.sp,
                    fontWeight: FontWeight.w400),
                SizedBox(
                  height: 30.h,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OrgChartTile(
                        rank: dutySoldiersAndRanks.values.elementAt(0),
                        name: dutySoldiersAndRanks.keys.elementAt(0),
                        heroTag: heroAddDutySoldiers[0],
                        callbackFunction: callBack,
                        nonParticipants: non_participants,
                        dutySoldiersAndRanks: dutySoldiersAndRanks,
                      ),
                      OrgChartTile(
                        rank: dutySoldiersAndRanks.values.elementAt(1),
                        name: dutySoldiersAndRanks.keys.elementAt(1),
                        heroTag: heroAddDutySoldiers[1],
                        callbackFunction: callBack,
                        nonParticipants: non_participants,
                        dutySoldiersAndRanks: dutySoldiersAndRanks,
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
                      rank: dutySoldiersAndRanks.values.elementAt(2),
                      name: dutySoldiersAndRanks.keys.elementAt(2),
                      heroTag: heroAddDutySoldiers[2],
                      callbackFunction: callBack,
                      nonParticipants: non_participants,
                      dutySoldiersAndRanks: dutySoldiersAndRanks,
                    ),
                    OrgChartTile(
                      rank: dutySoldiersAndRanks.values.elementAt(3),
                      name: dutySoldiersAndRanks.keys.elementAt(3),
                      heroTag: heroAddDutySoldiers[3],
                      callbackFunction: callBack,
                      nonParticipants: non_participants,
                      dutySoldiersAndRanks: dutySoldiersAndRanks,
                    ),
                    OrgChartTile(
                      rank: dutySoldiersAndRanks.values.elementAt(4),
                      name: dutySoldiersAndRanks.keys.elementAt(4),
                      heroTag: heroAddDutySoldiers[4],
                      callbackFunction: callBack,
                      nonParticipants: non_participants,
                      dutySoldiersAndRanks: dutySoldiersAndRanks,
                    ),
                    OrgChartTile(
                      rank: dutySoldiersAndRanks.values.elementAt(5),
                      name: dutySoldiersAndRanks.keys.elementAt(5),
                      heroTag: heroAddDutySoldiers[5],
                      callbackFunction: callBack,
                      nonParticipants: non_participants,
                      dutySoldiersAndRanks: dutySoldiersAndRanks,
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
                      rank: dutySoldiersAndRanks.values.elementAt(6),
                      name: dutySoldiersAndRanks.keys.elementAt(6),
                      heroTag: heroAddDutySoldiers[6],
                      callbackFunction: callBack,
                      nonParticipants: non_participants,
                      dutySoldiersAndRanks: dutySoldiersAndRanks,
                    ),
                    OrgChartTile(
                      rank: dutySoldiersAndRanks.values.elementAt(7),
                      name: dutySoldiersAndRanks.keys.elementAt(7),
                      heroTag: heroAddDutySoldiers[7],
                      callbackFunction: callBack,
                      nonParticipants: non_participants,
                      dutySoldiersAndRanks: dutySoldiersAndRanks,
                    ),
                    OrgChartTile(
                      rank: dutySoldiersAndRanks.values.elementAt(8),
                      name: dutySoldiersAndRanks.keys.elementAt(8),
                      heroTag: heroAddDutySoldiers[8],
                      callbackFunction: callBack,
                      nonParticipants: non_participants,
                      dutySoldiersAndRanks: dutySoldiersAndRanks,
                    ),
                    OrgChartTile(
                      rank: dutySoldiersAndRanks.values.elementAt(9),
                      name: dutySoldiersAndRanks.keys.elementAt(9),
                      heroTag: heroAddDutySoldiers[9],
                      callbackFunction: callBack,
                      nonParticipants: non_participants,
                      dutySoldiersAndRanks: dutySoldiersAndRanks,
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
                        Text(
                          "EXPECTED POINTS PER PERSON",
                          style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Text(
                          typeOfDay,
                          style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text("${points.toString()} Points",
                            style: GoogleFonts.poppins(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50.h,
                ),
                Column(
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
                          border: Border.all(
                              color: Theme.of(context).colorScheme.tertiary),
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
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                SizedBox(
                  height: 30.h,
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.dutyEndTime != "End Time:" &&
                        widget.dutyStartTime != "Start Time:" &&
                        widget.dutyDate != "Date of Duty:") {
                      IconSnackBar.show(
                          duration: const Duration(seconds: 1),
                          direction: DismissDirection.horizontal,
                          context: context,
                          snackBarType: SnackBarType.save,
                          label: 'Duty added successfully!',
                          snackBarStyle: const SnackBarStyle() // this one
                          );
                      addGaurdDuty();
                      Navigator.pop(context);
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
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_calendar_rounded,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          AutoSizeText(
                            'UPDATE GUARD DUTY',
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
