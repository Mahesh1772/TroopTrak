import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/conduct_provider.dart';
import '../widgets/conduct_calendar.dart';
import '../widgets/conduct_bar_graph.dart';
import '../widgets/conduct_list.dart';
import '../widgets/date_selector.dart';
import '../widgets/add_conduct_button.dart';
import '../widgets/no_conducts_widget.dart';
import '../../domain/entities/conduct.dart';
import '../../../../core/theme/theme_manager.dart';

class ConductTrackerScreen extends StatefulWidget {
  const ConductTrackerScreen({super.key});

  @override
  State<ConductTrackerScreen> createState() => _ConductTrackerScreenState();
}

class _ConductTrackerScreenState extends State<ConductTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Set the initial date to today when the screen is mounted
        context.read<ConductProvider>().updateSelectedDate(DateTime.now());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : Colors.white,
              isDarkMode ? const Color.fromARGB(255, 25, 30, 45) : Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conduct Tracker',
                                style: GoogleFonts.poppins(
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Track and manage conducts',
                                style: GoogleFonts.poppins(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 14.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.sp),
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? const Color.fromARGB(255, 45, 50, 65) 
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode 
                                          ? Colors.black.withOpacity(0.3) 
                                          : Colors.black.withOpacity(0.15),
                                      blurRadius: 16.r,
                                      offset: Offset(0, 6.h),
                                      spreadRadius: isDarkMode ? 1.r : 2.r,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                    onTap: () {
                                      context.read<ThemeManager>().toggleTheme(!isDarkMode);
                                    },
                                    child: Icon(
                                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                      color: isDarkMode 
                                          ? Colors.white.withOpacity(0.9)
                                          : theme.colorScheme.secondary,
                                      size: 24.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.all(8.sp),
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? const Color.fromARGB(255, 45, 50, 65) 
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode 
                                          ? Colors.black.withOpacity(0.3) 
                                          : Colors.black.withOpacity(0.15),
                                      blurRadius: 16.r,
                                      offset: Offset(0, 6.h),
                                      spreadRadius: isDarkMode ? 1.r : 2.r,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  color: isDarkMode 
                                      ? Colors.white.withOpacity(0.9)
                                      : theme.colorScheme.secondary,
                                  size: 24.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 240.w,
                            child: const DateSelector(),
                          ),
                          const AddConductButton(),
                        ],
                      ),
                    ],
                  ),
                ),
                const ConductCalendar(),
                SizedBox(height: 24.h),
                StreamBuilder<List<Conduct>>(
                  stream: context.watch<ConductProvider>().conducts,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.poppins(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 14.sp,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      );
                    }

                    final conducts = snapshot.data!;
                    final selectedDate = context.watch<ConductProvider>().selectedDate;
                    final todayConducts = context.read<ConductProvider>()
                        .filterConductsByDate(conducts, selectedDate);

                    if (todayConducts.isEmpty) {
                      return const NoConductsWidget();
                    }

                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? const Color.fromARGB(255, 45, 50, 65) 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode 
                                    ? Colors.black.withOpacity(0.3) 
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: ConductBarGraph(
                            conducts: todayConducts,
                            participationStrength: context
                                .read<ConductProvider>()
                                .getParticipationStrength(todayConducts),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ConductList(conducts: todayConducts),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 