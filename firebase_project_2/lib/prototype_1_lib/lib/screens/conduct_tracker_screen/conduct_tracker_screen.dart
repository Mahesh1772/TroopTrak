import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/conduct_tracker_screen/add_new_conduct_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/conduct_tracker_screen/conduct_details_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/conduct_tracker_screen/util/charts/bar_graph/bar_graph_styling.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/conduct_tracker_screen/util/conduct_main_page_tiles.dart';

import 'package:horizontal_center_date_picker/datepicker_controller.dart';
import 'package:horizontal_center_date_picker/horizontal_date_picker.dart';
import 'package:provider/provider.dart';

import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

class ConductTrackerScreen extends StatefulWidget {
  const ConductTrackerScreen({super.key});

  @override
  State<ConductTrackerScreen> createState() => _ConductTrackerScreenState();
}

class _ConductTrackerScreenState extends State<ConductTrackerScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> todayConducts = [];
  List<Map<String, dynamic>> allConducts = [];
  List<String> allParticipants = [];
  List<double> participant = [];
  List<String> participants = [];
  DateTime _selectedDate = DateTime.now();
  final DatePickerController _date = DatePickerController();

  // The DocID or the name of the current user is saved in here
  final name = FirebaseAuth.instance.currentUser!.displayName.toString();

  Map<String, dynamic> currentUserData = {};

  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> conductStream;

  Future getCurrentUserData() async {
    var data = FirebaseFirestore.instance.collection('Users').doc(name);
    data.get().then((DocumentSnapshot doc) {
      currentUserData = doc.data()! as Map<String, dynamic>;
      // ...
    });
  }

  @override
  void initState() {
    conductStream =
        FirebaseFirestore.instance.collection('Conducts').snapshots();
    getCurrentUserData();
    _selectedDate = DateTime.now();

    super.initState();
  }

  /// Returns the difference (in full days) between the provided date and today.
  int calculateDifference(DateTime date) {
    //DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day))
        .inDays;
  }

  @override
  Widget build(BuildContext context) {
    final conductModel = Provider.of<UserData>(context);
    var now = DateTime.now();
    DateTime startDate = DateTime(2022);

    DateTime endDate = DateTime(2025);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: conductModel.conducts_data,
            builder: (context, snapshot) {
              var conducts = snapshot.data?.docs.toList();
              if (snapshot.hasData) {
                todayConducts = [];
                allConducts = [];
                participant = [];
                participants = [];
                allParticipants = [];
                for (var i = 0; i < conducts!.length; i++) {
                  var data = conducts[i].data();
                  allConducts.add(data as Map<String, dynamic>);
                  allConducts[i]
                      .addEntries({'ID': conducts[i].reference.id}.entries);
                }
                for (var conduct in allConducts) {
                  if (calculateDifference(DateFormat("d MMM yyyy")
                          .parse(conduct['startDate'])) ==
                      0) {
                    todayConducts.add(conduct);
                  }
                  allParticipants.add(conduct['participants'].toString());
                }
                for (var conduct in todayConducts) {
                  participant.add(conduct['participants'].length.toDouble());
                  participants.add(conduct['participants'].toString());
                }
                allParticipants.removeWhere(
                  (element) => participants.contains(element),
                );
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2022),
                                lastDate: DateTime(2030),
                              ).then((value) {
                                setState(() {
                                  _selectedDate = value!;
                                  _date.scrollTo(_selectedDate);
                                  _date.selectedDate = _selectedDate;
                                });
                              });
                            },
                            child: Icon(
                              Icons.date_range_rounded,
                              color: Colors.white,
                              size: 45.sp,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMMd().format(DateTime.now()),
                                style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 22.sp),
                              ),
                              Text(
                                "Today",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 28.sp),
                              ),
                            ],
                          ),
                          GestureDetector(
                            key: const Key("addConductPageRedirectButton"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddNewConductScreen(
                                    selectedConductType: "Select conduct...",
                                    conductName: TextEditingController(),
                                    startDate: "Date:",
                                    startTime: "Start Time:",
                                    endTime: "End Time:",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.0.sp),
                              height: 60.h,
                              width: 180.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 72, 30, 229),
                                    Color.fromARGB(255, 130, 60, 229),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  StyledText("Add Conduct", 18.sp,
                                      fontWeight: FontWeight.w400),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20.w),
                      child: HorizontalDatePickerWidget(
                        startDate: startDate,
                        endDate: endDate,
                        height: 110.h,
                        width: 80.w,
                        widgetWidth: MediaQuery.of(context).size.width,
                        selectedDate: now,
                        onValueSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        datePickerController: _date,
                        normalColor: const Color.fromARGB(255, 21, 25, 34),
                        selectedColor: const Color.fromARGB(255, 72, 30, 229),
                        disabledColor: const Color.fromARGB(255, 21, 25, 34),
                        normalTextColor: Colors.white,
                        monthTextStyle: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                        dayTextStyle: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        weekDayTextStyle: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    todayConducts.isEmpty
                        ? Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset("lib/assets/noConductspng.png"),
                                StyledText("NO CONDUCTS FOR TODAY!", 28.sp,
                                    fontWeight: FontWeight.w500),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 20.0.w),
                                child: StyledText(
                                    "Participation Strength", 24.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Container(
                                height: 450.h,
                                padding: EdgeInsets.all(16.0.sp),
                                child: BarGraphStyling(
                                  totalStrength: allConducts.length.toDouble(),
                                  conductList: todayConducts,
                                  participationStrength: participant,
                                ),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 20.0.w),
                                child: StyledText(
                                    "Conducts Completed / Ongoing", 24.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: todayConducts.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ConductDetailsScreen(
                                            conductID: todayConducts[index]
                                                ['ID'],
                                            //nonParticipants: allParticipants,
                                            participants: todayConducts[index]
                                                ['participants'],
                                            conductName: todayConducts[index]
                                                ['conductName'],
                                            conductType: todayConducts[index]
                                                ['conductType'],
                                            startDate: todayConducts[index]
                                                ['startDate'],
                                            startTime: todayConducts[index]
                                                ['startTime'],
                                            endTime: todayConducts[index]
                                                ['endTime'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: ConductTile(
                                      conductNumber: index.toInt(),
                                      conductName: todayConducts[index]
                                          ['conductName'],
                                      conductType: todayConducts[index]
                                          ['conductType'],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: 30.h,
                              )
                            ],
                          )
                  ],
                );
              }
              return const Text('Loading......');
            },
          ),
        ),
      ),
    );
  }
}
