import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/conduct_provider.dart';
import 'package:intl/intl.dart';

class ConductCalendar extends StatefulWidget {
  const ConductCalendar({super.key});

  @override
  State<ConductCalendar> createState() => _ConductCalendarState();
}

class _ConductCalendarState extends State<ConductCalendar> {
  final ScrollController _scrollController = ScrollController();
  final double dayWidth = 80.w;  // Fixed width for each day item
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(ConductCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousDate = context.read<ConductProvider>().selectedDate;
    final currentDate = context.watch<ConductProvider>().selectedDate;
    
    if (previousDate != currentDate) {
      _scrollToSelectedDate();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    if (!mounted) return;
    
    final selectedDate = context.read<ConductProvider>().selectedDate;
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    
    // Calculate the index of the selected date relative to the start of the week
    final daysDifference = selectedDate.difference(startOfWeek).inDays;
    
    // Calculate scroll position
    final scrollPosition = daysDifference * (dayWidth + 12.w); // dayWidth + spacing
    
    // Animate to the position
    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final selectedDate = context.watch<ConductProvider>().selectedDate;

    // Generate dates for the week
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final dates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    // Add listener for date changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToSelectedDate();
      }
    });

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          SizedBox(width: 16.w),  // Initial padding
          ...dates.map((date) {
            final isSelected = DateFormat('d MMM yyyy').format(date) == 
                             DateFormat('d MMM yyyy').format(selectedDate);
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () {
                  context.read<ConductProvider>().updateSelectedDate(date);
                },
                child: Container(
                  width: dayWidth,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.secondary,
                              theme.colorScheme.secondary.withOpacity(0.8),
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : isDarkMode
                            ? const Color.fromARGB(255, 45, 50, 65)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? theme.colorScheme.secondary.withOpacity(0.3)
                            : isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                        blurRadius: 8.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? Colors.white
                              : isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                          fontSize: 14.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        date.day.toString(),
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? Colors.white
                              : isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('MMM').format(date),
                        style: GoogleFonts.poppins(
                          color: isSelected
                              ? Colors.white
                              : isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                          fontSize: 12.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          SizedBox(width: 4.w),  // Final padding
        ],
      ),
    );
  }
} 
