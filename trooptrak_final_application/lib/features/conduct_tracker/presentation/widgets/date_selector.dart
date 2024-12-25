import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/conduct_provider.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final selectedDate = context.watch<ConductProvider>().selectedDate;

    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDarkMode 
                ? const Color.fromARGB(255, 45, 50, 65) 
                : Colors.white,
            isDarkMode 
                ? const Color.fromARGB(255, 40, 45, 60) 
                : Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.1),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2022),
              lastDate: DateTime(2025),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: theme.colorScheme.secondary,
                      onPrimary: Colors.white,
                      surface: isDarkMode 
                          ? const Color.fromARGB(255, 45, 50, 65) 
                          : Colors.white,
                      onSurface: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                      ),
                    ),
                    dialogBackgroundColor: isDarkMode 
                        ? const Color.fromARGB(255, 35, 40, 55) 
                        : Colors.white,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && context.mounted) {
              context.read<ConductProvider>().updateSelectedDate(picked);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: isDarkMode 
                        ? Colors.white.withOpacity(0.9)
                        : theme.colorScheme.secondary,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    DateFormat('d MMM yyyy').format(selectedDate),
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.7)
                    : theme.colorScheme.secondary.withOpacity(0.7),
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 