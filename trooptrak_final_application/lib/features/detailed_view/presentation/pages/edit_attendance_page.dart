import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/attendance_record.dart';
import '../providers/attendance_provider.dart';
import 'package:provider/provider.dart';

class EditAttendancePage extends StatefulWidget {
  final String userId;
  final AttendanceRecord record;

  const EditAttendancePage({
    super.key,
    required this.userId,
    required this.record,
  });

  @override
  _EditAttendancePageState createState() => _EditAttendancePageState();
}

class _EditAttendancePageState extends State<EditAttendancePage> {
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateFormat("EEE d MMM yyyy HH:mm:ss").parse(widget.record.dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button and Title
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back_sharp,
                    color: theme.colorScheme.tertiary,
                    size: 25.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "Update Attendance  ✍️",
                  style: GoogleFonts.poppins(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                Text(
                  "Edit the attendance record details",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w300,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                SizedBox(height: 32.h),

                // Date and Time Picker
                InkWell(
                  onTap: _selectDateTime,
                  child: Container(
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date and Time',
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.tertiary.withOpacity(0.7),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                DateFormat('EEE d MMM yyyy HH:mm:ss').format(selectedDateTime),
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.tertiary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            color: theme.colorScheme.tertiary,
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Status Switch
                Container(
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: GoogleFonts.poppins(
                                color: theme.colorScheme.tertiary.withOpacity(0.7),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.record.isInsideCamp ? 'Inside Camp' : 'Outside Camp',
                              style: GoogleFonts.poppins(
                                color: theme.colorScheme.tertiary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: widget.record.isInsideCamp,
                          onChanged: (bool value) {
                            setState(() {
                              widget.record.isInsideCamp = value;
                            });
                          },
                          activeColor: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: Icon(
                      Icons.save_rounded,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                    label: Text(
                      'SAVE CHANGES',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 14.sp,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.secondary,
              onPrimary: Colors.white,
              surface: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
              onSurface: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary,
              ),
            ),
            dialogBackgroundColor: isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        builder: (context, child) {
          final theme = Theme.of(context);
          final isDarkMode = theme.brightness == Brightness.dark;
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: theme.colorScheme.secondary,
                onPrimary: Colors.white,
                surface: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
                onSurface: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                ),
              ),
              dialogBackgroundColor: isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : Colors.white,
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveChanges() {
    final updatedRecord = AttendanceRecord(
      id: widget.record.id,
      dateTime: DateFormat('EEE d MMM yyyy HH:mm:ss').format(selectedDateTime),
      isInsideCamp: widget.record.isInsideCamp, // Maintain original status
    );
    
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    attendanceProvider.updateAttendanceRecord(widget.userId, updatedRecord).listen(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Attendance record updated successfully',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating attendance record: $error',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}
