import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NoConductsWidget extends StatelessWidget {
  const NoConductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode 
              ? const Color.fromARGB(255, 45, 50, 65)
              : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 16.r,
              offset: Offset(0, 8.h),
              spreadRadius: 2.r,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.black.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.7)
                    : theme.colorScheme.secondary,
                size: 48.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Conducts Scheduled',
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'There are no conducts scheduled for this date',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 16.sp,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 