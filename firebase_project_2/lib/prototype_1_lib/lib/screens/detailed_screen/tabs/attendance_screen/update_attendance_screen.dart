// ignore_for_file: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class UpdateAttendanceScreen extends StatefulWidget {
  UpdateAttendanceScreen(
      {super.key,
      required this.docID,
      required this.attendanceID,
      required this.isToggled});

  late String docID;
  late String attendanceID;
  final bool isToggled;

  @override
  State<UpdateAttendanceScreen> createState() => _UpdateAttendanceScreenState();
}

class _UpdateAttendanceScreenState extends State<UpdateAttendanceScreen> {
  final _formKey = GlobalKey<FormState>();

  late List<String> dateTime;
  late String date;
  late String time;

  @override
  void initState() {
    super.initState();
    dateTime = widget.attendanceID.split(' ');
    date = dateTime[0];
    DateTime newDate = DateFormat('yyyy-MM-dd').parse(date);
    date = DateFormat('E d MMM yyyy').format(newDate);
    time = dateTime[1];
    DateTime newTime = DateFormat('HH:mm:ss').parse(time);
    time = DateFormat('h:mm a').format(newTime);
    print(widget.attendanceID);
  }

  void _showStartDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        date = DateFormat('E d MMM yyyy').format(value!);
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

              time = DateFormat.jm().format(dt);
            }
          },
        );
      }),
    );
  }

  Future updateAttendance() async {
    DateTime newTime = DateFormat('h:mm a').parse(time);
    time = DateFormat('HH:mm:ss').format(newTime);
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.docID)
        .collection('Attendance')
        .doc(widget.attendanceID)
        .update({
      //User map formatting
      'date&time': "$date $time",
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isToggled ? Colors.white : Colors.black;
    //final userStatusModel = Provider.of<UserData>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: widget.isToggled
          ? const Color.fromARGB(255, 21, 25, 34)
          : const Color.fromARGB(255, 243, 246, 254),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      //goBackWithoutChanges();
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_sharp,
                      color: textColor,
                      size: 25.sp,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    "Edit Attendance",
                    style: GoogleFonts.poppins(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "Fill in book in / book out time.",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w300,
                      color: textColor,
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),

                  InkWell(
                    onTap: () {
                      _showStartDatePicker();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(
                          color: textColor,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 15.h),
                            child: AutoSizeText(
                              date,
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

                  //Status end date picker
                  InkWell(
                    onTap: () {
                      _showStartTimePicker();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(
                          color: textColor,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 15.h),
                            child: AutoSizeText(
                              time,
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
                    height: 40.h,
                  ),

                  GestureDetector(
                    onTap: updateAttendance,
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
                              Icons.edit_attributes_rounded,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            AutoSizeText(
                              'EDIT ATTENDANCE',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
