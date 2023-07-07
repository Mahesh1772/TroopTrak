import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({super.key});

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends State<DashboardCalendar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 780.h,
      child: SfCalendar(
        backgroundColor: Colors.black54,
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
        view: CalendarView.schedule,
        scheduleViewMonthHeaderBuilder: scheduleViewHeaderBuilder,
        scheduleViewSettings: ScheduleViewSettings(
          appointmentItemHeight: 70.h,
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
