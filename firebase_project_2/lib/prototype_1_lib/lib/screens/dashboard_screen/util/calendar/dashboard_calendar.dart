import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({super.key});

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

DateTime _selectedDate = DateTime.now();
List<Appointment> meetings = <Appointment>[];

class _DashboardCalendarState extends State<DashboardCalendar> {
  final CalendarController _controller = CalendarController();

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (_controller.view == CalendarView.month &&
        calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      _controller.view = CalendarView.day;
    } else if ((_controller.view == CalendarView.week ||
            _controller.view == CalendarView.workWeek) &&
        calendarTapDetails.targetElement == CalendarElement.viewHeader) {
      _controller.view = CalendarView.day;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final statusModel = Provider.of<UserData>(context);
    return SizedBox(
      height: 780.h,
      child: StreamBuilder2<QuerySnapshot, QuerySnapshot>(
        streams: StreamTuple2(statusModel.conducts_data, statusModel.duty_data),
        builder: (context, snapshots) {
          if (snapshots.snapshot1.hasData) {
            var conducts = snapshots.snapshot1.data?.docs.toList();
            meetings = [];
            var allConducts = [];
            for (var i = 0; i < conducts!.length; i++) {
              var data = conducts[i].data();
              allConducts.add(data as Map<String, dynamic>);
              allConducts[i]
                  .addEntries({'ID': conducts[i].reference.id}.entries);
            }
            for (var conduct in allConducts) {
              String nowStrartTime =
                  conduct['startDate'] + " " + conduct['startTime'];
              DateTime sDate =
                  DateFormat('d MMM yyyy h:mm a').parse(nowStrartTime);

              DateTime eDate;
              if (conduct['endTime'].contains('AM') &&
                  conduct['startTime'].contains('PM')) {
                DateTime newDate =
                    DateFormat('d MMM yyyy').parse(conduct['startDate']);
                newDate =
                    DateTime(newDate.year, newDate.month, newDate.day + 1);
                String dateOfDuty = DateFormat('d MMM yyyy').format(newDate);
                String nowEndTime = dateOfDuty + " " + conduct['endTime'];
                eDate = DateFormat('d MMM yyyy').add_jm().parse(nowEndTime);
              } else if (conduct['endTime'] == conduct['startTime']) {
                DateTime newDate =
                    DateFormat('d MMM yyyy').parse(conduct['startDate']);
                newDate =
                    DateTime(newDate.year, newDate.month, newDate.day + 1);
                String dateOfDuty = DateFormat('d MMM yyyy').format(newDate);
                String nowEndTime = dateOfDuty + " " + conduct['endTime'];
                eDate = DateFormat('d MMM yyyy').add_jm().parse(nowEndTime);
              } else {
                String nowEndTime =
                    conduct['startDate'] + " " + conduct['endTime'];
                eDate = DateFormat('d MMM yyyy h:mm a').parse(nowEndTime);
              }

              final Appointment newAppointment = Appointment(
                startTime: sDate,
                endTime: eDate,
                subject: conduct['conductType'],
                color: Colors.amber,
              );
              meetings.add(newAppointment);
            }
          }
          if (snapshots.snapshot2.hasData) {
            var dutyDetails = [];
            var duties = snapshots.snapshot2.data?.docs.toList();
            for (var i = 0; i < duties!.length; i++) {
              var data = duties[i].data();
              dutyDetails.add(data as Map<String, dynamic>);
              dutyDetails[i].addEntries({'ID': duties[i].reference.id}.entries);
            }

            for (var duty in dutyDetails) {
              String nowStrartTime = duty['dutyDate'] + " " + duty['startTime'];
              DateTime sDate =
                  DateFormat('d MMM yyyy').add_jm().parse(nowStrartTime);
              DateTime eDate;
              if (duty['endTime'].contains('AM') &&
                  duty['startTime'].contains('PM')) {
                DateTime newDate =
                    DateFormat('d MMM yyyy').parse(duty['dutyDate']);
                newDate =
                    DateTime(newDate.year, newDate.month, newDate.day + 1);
                String dateOfDuty = DateFormat('d MMM yyyy').format(newDate);
                String nowEndTime = dateOfDuty + " " + duty['endTime'];
                eDate = DateFormat('d MMM yyyy').add_jm().parse(nowEndTime);
              } else if (duty['endTime'] == duty['startTime']) {
                DateTime newDate =
                    DateFormat('d MMM yyyy').parse(duty['dutyDate']);
                newDate =
                    DateTime(newDate.year, newDate.month, newDate.day + 1);
                String dateOfDuty = DateFormat('d MMM yyyy').format(newDate);
                String nowEndTime = dateOfDuty + " " + duty['endTime'];
                eDate = DateFormat('d MMM yyyy').add_jm().parse(nowEndTime);
              } else {
                String nowEndTime = duty['dutyDate'] + " " + duty['endTime'];
                eDate = DateFormat('d MMM yyyy').add_jm().parse(nowEndTime);
              }

              final Appointment newAppointment = Appointment(
                startTime: sDate,
                endTime: eDate,
                subject: 'Guard Duty',
                color: Colors.pink,
              );
              meetings.add(newAppointment);
            }
          }
          return Scaffold(
            body: SfCalendarTheme(
              data: SfCalendarThemeData(
                brightness: Theme.of(context).brightness,
                backgroundColor: Theme.of(context).colorScheme.background,
              ),
              child: SfCalendar(
                blackoutDatesTextStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 18.sp,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                allowedViews: const [
                  CalendarView.day,
                  CalendarView.month,
                  CalendarView.timelineDay,
                  CalendarView.schedule
                ],
                showNavigationArrow: true,
                cellEndPadding: 5.sp,
                todayHighlightColor: Colors.deepPurple.shade400,
                selectionDecoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.deepPurple.shade400, width: 2.w),
                  borderRadius: BorderRadius.all(Radius.circular(4.r)),
                  shape: BoxShape.rectangle,
                ),
                controller: _controller,
                allowViewNavigation: true,
                showCurrentTimeIndicator: true,
                cellBorderColor: Theme.of(context).colorScheme.tertiary,
                appointmentTextStyle: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500),
                onTap: calendarTapped,
                monthViewSettings: MonthViewSettings(
                  navigationDirection: MonthNavigationDirection.vertical,
                  agendaStyle: AgendaStyle(
                    appointmentTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    dayTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    dateTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  monthCellStyle: MonthCellStyle(
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    trailingDatesTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.7),
                    ),
                    leadingDatesTextStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withOpacity(0.7),
                    ),
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.background,
                showDatePickerButton: true,
                headerStyle: CalendarHeaderStyle(
                  backgroundColor: Colors.deepPurple.shade400,
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 24.sp,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                todayTextStyle: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                viewHeaderStyle: ViewHeaderStyle(
                  dateTextStyle: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  dayTextStyle: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                view: CalendarView.schedule,
                dataSource: _getCalendarDataSource(),
                initialSelectedDate: _selectedDate,
                scheduleViewMonthHeaderBuilder: scheduleViewHeaderBuilder,
                timeSlotViewSettings: TimeSlotViewSettings(
                  //numberOfDaysInView: 1,
                  timeIntervalHeight: 100.h,
                  timeTextStyle: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                  ),
                ),
                scheduleViewSettings: ScheduleViewSettings(
                  appointmentItemHeight: 50.h,
                  appointmentTextStyle: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                  dayHeaderSettings: DayHeaderSettings(
                    dayFormat: 'EEEE',
                    width: 70.w,
                    dayTextStyle: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    dateTextStyle: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.tertiary,
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
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.7)),
                  ),
                  placeholderTextStyle: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
            ),
          );
        },
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
          child: AutoSizeText(
            '$monthName ${details.date.year}',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
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

MeetingDataSource _getCalendarDataSource() {
  return MeetingDataSource(meetings);
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
