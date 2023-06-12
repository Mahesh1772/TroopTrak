import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/screens/conduct_tracker_screen/add_new_conduct_screen.dart';
import 'package:prototype_1/screens/conduct_tracker_screen/conduct_details_screen.dart';
import 'package:prototype_1/screens/detailed_screen/tabs/user_profile_tabs/user_profile_screen.dart';
import 'package:prototype_1/screens/conduct_tracker_screen/util/charts/bar_graph/bar_graph_styling.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/screens/conduct_tracker_screen/util/conduct_main_page_tiles.dart';

class ConductTrackerScreen extends StatefulWidget {
  const ConductTrackerScreen({super.key});

  @override
  State<ConductTrackerScreen> createState() => _ConductTrackerScreenState();
}

class _ConductTrackerScreenState extends State<ConductTrackerScreen> {
  List<Map<String, dynamic>> todayConducts = [];
  List<Map<String, dynamic>> allConducts = [];
  List<String> allParticipants = [];
  List<double> participant = [];
  List<String> participants = [];
  DateTime _selectedDate = DateTime.now();
  DatePickerController _date = DatePickerController();

  // The DocID or the name of the current user is saved in here
  final name = FirebaseAuth.instance.currentUser!.displayName.toString();

  Map<String, dynamic> currentUserData = {};

  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> conductStream;

  Future getCurrentUserData() async {
    var data = FirebaseFirestore.instance.collection('Users').doc(name);
    data.get().then((DocumentSnapshot doc) {
      currentUserData = doc.data() as Map<String, dynamic>;
      // ...
    });
  }

  void executeAfterBuild() {
    _date.animateToDate(_selectedDate);
  }

  @override
  void initState() {
    conductStream =
        FirebaseFirestore.instance.collection('Conducts').snapshots();
    getCurrentUserData();

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: conductStream,
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
                //print(participants);

                print(todayConducts);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                          child: StyledText(
                            'Conduct Tracker',
                            26.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(
                                  soldierName: currentUserData['name'],
                                  soldierRank:
                                      "lib/assets/army-ranks/${currentUserData['rank'].toString().toLowerCase()}.png",
                                  soldierAppointment:
                                      currentUserData['appointment'],
                                  company: currentUserData['company'],
                                  platoon: currentUserData['platoon'],
                                  section: currentUserData['section'],
                                  dateOfBirth: currentUserData['dob'],
                                  rationType: currentUserData['rationType'],
                                  bloodType: currentUserData['bloodgroup'],
                                  enlistmentDate: currentUserData['enlistment'],
                                  ordDate: currentUserData['ord'],
                                ),
                              ),
                            );
                          },
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
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              ).then((value) {
                                setState(() {
                                  _selectedDate = value!;
                                  executeAfterBuild();
                                });
                              });
                            },
                            child: const Icon(
                              Icons.date_range_rounded,
                              color: Colors.white,
                              size: 50,
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
                                    fontSize: 24.sp),
                              ),
                              Text(
                                "Today",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 30.sp),
                              ),
                            ],
                          ),
                          GestureDetector(
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
                      height: 20.h,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: DatePicker(
                        DateTime(2020),
                        height: 110.h,
                        width: 80.w,
                        initialSelectedDate: DateTime.now(),
                        daysCount: 2000,
                        onDateChange: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        controller: _date,
                        selectionColor: const Color.fromARGB(255, 72, 30, 229),
                        selectedTextColor: Colors.white,
                        dayTextStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                        ),
                        monthTextStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                        dateTextStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: StyledText("Participation Strength", 24.sp,
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
                      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                      child: StyledText("Conducts Completed / Ongoing", 24.sp,
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
                                builder: (context) => ConductDetailsScreen(
                                  conductID: todayConducts[index]['ID'],
                                  nonParticipants: allParticipants,
                                  participants: todayConducts[index]
                                      ['participants'],
                                  conductName: todayConducts[index]
                                      ['conductName'],
                                  conductType: todayConducts[index]
                                      ['conductType'],
                                  startDate: todayConducts[index]['startDate'],
                                  startTime: todayConducts[index]['startTime'],
                                  endTime: todayConducts[index]['endTime'],
                                ),
                              ),
                            );
                          },
                          child: ConductTile(
                            conductNumber: index.toInt(),
                            conductName: todayConducts[index]['conductName'],
                            conductType: todayConducts[index]['conductType'],
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20.h,
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
