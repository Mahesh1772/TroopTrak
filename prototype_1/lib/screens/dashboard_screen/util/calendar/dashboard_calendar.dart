import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../user_models/user_details.dart';

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({super.key});

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

DateTime _selectedDate = DateTime.now();
List<Appointment> meetings = <Appointment>[];

class _DashboardCalendarState extends State<DashboardCalendar> {
  Stream<QuerySnapshot<Map<String, dynamic>>> stream1 =
      FirebaseFirestore.instance.collection('collection1').snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> stream2 =
      FirebaseFirestore.instance.collection('collection2').snapshots();

  @override
  void initState() {
    // TODO: implement initState
    getDuty_and_Conducts(context);
    super.initState();
  }

  @override
  build(BuildContext context) async {
    return SizedBox(
      height: 780.h,
      child: SfCalendar(
        //backgroundColor: Colors.black54,
        showDatePickerButton: true,
        headerStyle: CalendarHeaderStyle(
          backgroundColor: Colors.deepPurple,
          textStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 24.sp,
          ),
          textAlign: TextAlign.center,
        ),
        todayTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16.sp,
        ),
        viewHeaderStyle: ViewHeaderStyle(
          backgroundColor: Colors.deepPurple,
          dateTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24.sp,
          ),
          dayTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24.sp,
          ),
        ),
        view: CalendarView.week,
        dataSource: MeetingDataSource(meetings),
        initialSelectedDate: _selectedDate,
        scheduleViewMonthHeaderBuilder: scheduleViewHeaderBuilder,
        timeSlotViewSettings: const TimeSlotViewSettings(
          numberOfDaysInView: 3,
          timeIntervalHeight: 100,
        ),
        scheduleViewSettings: ScheduleViewSettings(
          appointmentItemHeight: 50.h,
          appointmentTextStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
          dayHeaderSettings: DayHeaderSettings(
            dayFormat: 'EEEE',
            width: 70.w,
            dayTextStyle: GoogleFonts.poppins(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            dateTextStyle: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          monthHeaderSettings: MonthHeaderSettings(
            backgroundColor: Colors.deepPurple,
            monthTextStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          weekHeaderSettings: WeekHeaderSettings(
            weekTextStyle: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          placeholderTextStyle: GoogleFonts.poppins(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget scheduleViewHeaderBuilder(
      BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
    final String monthName = _getMonthName(details.date.month);
    return Stack(
      children: [
        Image(
          image: ExactAssetImage('lib/assets/calendar-images/$monthName.png'),
          fit: BoxFit.cover,
          width: details.bounds.width,
          height: details.bounds.height,
        ),
        Positioned(
          left: 55.w,
          right: 0.w,
          top: 20.h,
          bottom: 0.h,
          child: Text(
            '$monthName ${details.date.year}',
            style: GoogleFonts.poppins(
                fontSize: 20.sp, fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }

  String _getMonthName(int month) {
    if (month == 01) {
      return 'January';
    } else if (month == 02) {
      return 'February';
    } else if (month == 03) {
      return 'March';
    } else if (month == 04) {
      return 'April';
    } else if (month == 05) {
      return 'May';
    } else if (month == 06) {
      return 'June';
    } else if (month == 07) {
      return 'July';
    } else if (month == 08) {
      return 'August';
    } else if (month == 09) {
      return 'September';
    } else if (month == 10) {
      return 'October';
    } else if (month == 11) {
      return 'November';
    } else {
      return 'December';
    }
  }
}

List<Appointment> getAppointments() {
  final DateTime today = DateTime.now();
  final DateTime startTime =
      DateTime(today.year, today.month, today.day, 9, 0, 0);
  final DateTime endTime = startTime.add(const Duration(hours: 2));

  meetings.add(Appointment(
      startTime: startTime,
      endTime: endTime,
      subject: 'Board Meeting',
      color: Colors.blue,
      recurrenceRule: 'FREQ=DAILY;COUNT=10',
      isAllDay: false));

  return meetings;
}

int calculateDifference(DateTime date) {
  //DateTime now = DateTime.now();
  return DateTime(date.year, date.month, date.day)
      .difference(
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day))
      .inDays;
}

Future<List<Appointment>> getDuty_and_Conducts(BuildContext context) async {
  final userDetailsModel = Provider.of<UserData>(context);
  List<Map<String, dynamic>> todayConducts =
      await userDetailsModel.todayConducts();
//List<Map<String, dynamic>> allConducts = [];
  List<Map<String, dynamic>> dutyDetails = await userDetailsModel.todayDuty();

  print(dutyDetails);
  //StreamBuilder2<QuerySnapshot, QuerySnapshot>(
  //  streams: StreamTuple2(
  //      userDetailsModel.conducts_data, userDetailsModel.duty_data),
  //  builder: (context, snapshots) {
  //    if (snapshots.snapshot1.hasData) {
  //      var conducts = snapshots.snapshot1.data?.docs.toList();
  //      todayConducts = [];
  //      allConducts = [];
  //      for (var i = 0; i < conducts!.length; i++) {
  //        var data = conducts[i].data();
  //        allConducts.add(data as Map<String, dynamic>);
  //        allConducts[i].addEntries({'ID': conducts[i].reference.id}.entries);
  //      }
  //      for (var conduct in allConducts) {
  //        if (calculateDifference(
  //                DateFormat("d MMM yyyy").parse(conduct['startDate'])) ==
  //            0) {
  //          todayConducts.add(conduct);
  //        }
  //      }
  for (var conduct in todayConducts) {
    meetings.add(
      Appointment(
          startTime: conduct['startTime'],
          endTime: conduct['endTime'],
          subject: conduct['conductName'],
          color: Colors.amber),
    );
  }
  //    }
  //    if (snapshots.snapshot2.hasData) {
  //      dutyDetails = [];
  //      var duties = snapshots.snapshot2.data?.docs.toList();
  //      for (var i = 0; i < duties!.length; i++) {
  //        var data = duties[i].data();
  //        if (calculateDifference(
  //                DateFormat("d MMM yyyy").parse(duties[i]['dutyDate'])) ==
  //            0) {
  //          dutyDetails.add(data as Map<String, dynamic>);
  //          dutyDetails[i].addEntries({'ID': duties[i].reference.id}.entries);
  //        }
  //      }
  for (var conduct in dutyDetails) {
    meetings.add(
      Appointment(
          startTime: conduct['startTime'],
          endTime: conduct['endTime'],
          subject: conduct['dayType'],
          color: Colors.amber),
    );
  }
  //    }
  //    return Text('null');
  //  },
  //);

  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
