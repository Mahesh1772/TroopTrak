import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../nominal_roll/domain/entities/attendance_record.dart';
import '../../../nominal_roll/presentation/providers/user_detail_provider.dart';

class AttendanceTab extends StatelessWidget {
  final String userId;

  const AttendanceTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<UserDetailProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<AttendanceRecord>>(
            stream: provider.getUserAttendance(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: const Color.fromARGB(255, 72, 30, 229),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.error,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                );
              }

              final records = snapshot.data ?? [];
              if (records.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 50.sp,
                        color: theme.colorScheme.error,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'No attendance records found',
                        style: GoogleFonts.poppins(
                          color: theme.colorScheme.tertiary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.all(30.sp),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.outbond,
                            size: 30.sp,
                            color: theme.colorScheme.tertiary,
                          ),
                          SizedBox(width: 20.w),
                          Text(
                            "Book In / Book Out",
                            maxLines: 2,
                            style: GoogleFonts.poppins(
                              color: theme.colorScheme.tertiary,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 650.h,
                        child: ListView.builder(
                          itemCount: records.length,
                          padding: EdgeInsets.all(12.sp),
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 15.h),
                              padding: EdgeInsets.all(15.sp),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.dateTime,
                                        style: GoogleFonts.poppins(
                                          color: theme.colorScheme.tertiary,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Text(
                                        record.isInsideCamp ? 'Inside Camp' : 'Outside Camp',
                                        style: GoogleFonts.poppins(
                                          color: record.isInsideCamp
                                              ? const Color.fromARGB(255, 72, 30, 229)
                                              : theme.colorScheme.error,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    record.isInsideCamp
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.cancel_outlined,
                                    color: record.isInsideCamp
                                        ? const Color.fromARGB(255, 72, 30, 229)
                                        : theme.colorScheme.error,
                                    size: 30.sp,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
