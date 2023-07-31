import 'package:firebase_project_2/prototype_1_lib/lib/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/util/guard_duty_main_page_tiles.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

class UpcomingDuties extends StatefulWidget {
  const UpcomingDuties({super.key});

  @override
  State<UpcomingDuties> createState() => _UpcomingDutiesState();
}

//Stream we listen to
late Stream<QuerySnapshot> documentStream;

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> dutyDetails = [];

//List to store the selected date's guard duties
List<Map<String, dynamic>> todayDuties = [];

//Loop variable
int i = 0;

class _UpcomingDutiesState extends State<UpcomingDuties>
    with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
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
    final userDetailsModel = Provider.of<UserData>(context);
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                child: StyledText("Today's Duties", 24.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15.h,
              ),
              Container(
                margin: EdgeInsets.only(
                  top: defaultPadding.h,
                ),
                padding: EdgeInsets.all(defaultPadding.sp),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2.w,
                    color: const Color.fromARGB(255, 72, 30, 229)
                        .withOpacity(0.35),
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(defaultPadding),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        ).then(
                          (value) {
                            setState(
                              () {
                                _selectedDate = value!;
                              },
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.date_range_rounded,
                        color: Colors.white,
                        size: 45.sp,
                      ),
                    ),
                    SizedBox(
                      width: 30.w,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMMd().format(_selectedDate),
                          style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontWeight: FontWeight.w400,
                              fontSize: 28.sp),
                        ),
                        Text(
                          _selectedDate == DateTime.now()
                              ? "Today"
                              : DateFormat('EEEE').format(_selectedDate),
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 32.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: userDetailsModel.duty_data,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    todayDuties = [];
                    dutyDetails = [];
                    var duties = snapshot.data?.docs.toList();

                    for (var i = 0; i < duties!.length; i++) {
                      var data = duties[i].data();
                      dutyDetails.add(data as Map<String, dynamic>);
                      dutyDetails[i]
                          .addEntries({'ID': duties[i].reference.id}.entries);
                    }
                    for (var duty in dutyDetails) {
                      if (calculateDifference(DateFormat("d MMM yyyy")
                              .parse(duty['dutyDate'])) ==
                          0) {
                        todayDuties.add(duty);
                      }
                    }
                  }
                  return todayDuties.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const PageScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: todayDuties.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {},
                              child: GuardDutyTile(
                                docID: todayDuties[index]['ID'],
                                participants: todayDuties[index]
                                    ['participants'],
                                dutyDate: todayDuties[index]['dutyDate'],
                                startTime: todayDuties[index]['startTime'],
                                endTime: todayDuties[index]['endTime'],
                                dutyType: todayDuties[index]['dayType'],
                                numberOfPoints: todayDuties[index]['points'],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset("lib/assets/noConductspng.png"),
                              StyledText("NO DUTIES FOR TODAY!", 28.sp,
                                  fontWeight: FontWeight.w500),
                            ],
                          ),
                        );
                },
              ),
              SizedBox(
                height: 50.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                child: StyledText("Upcoming Duties", 24.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15.h,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: userDetailsModel.duty_data,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      dutyDetails = [];
                      var duties = snapshot.data?.docs.toList();

                      for (var i = 0; i < duties!.length; i++) {
                        var data = duties[i].data();
                        dutyDetails.add(data as Map<String, dynamic>);
                        dutyDetails[i]
                            .addEntries({'ID': duties[i].reference.id}.entries);
                      }
                      dutyDetails = dutyDetails
                          .where((element) =>
                              calculateDifference(DateFormat('d MMM yyyy')
                                  .parse(element['dutyDate'])) >=
                              1)
                          .toList();
                    }
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const PageScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: dutyDetails.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {},
                          child: GuardDutyTile(
                            docID: dutyDetails[index]['ID'],
                            participants: dutyDetails[index]['participants'],
                            dutyDate: dutyDetails[index]['dutyDate'],
                            startTime: dutyDetails[index]['startTime'],
                            endTime: dutyDetails[index]['endTime'],
                            dutyType: dutyDetails[index]['dayType'],
                            numberOfPoints: dutyDetails[index]['points'],
                          ),
                        );
                      },
                    );
                  }),
              SizedBox(
                height: 50.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
