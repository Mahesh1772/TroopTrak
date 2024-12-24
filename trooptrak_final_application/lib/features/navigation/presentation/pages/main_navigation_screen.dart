import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../conduct_tracker/presentation/pages/conduct_tracker_screen.dart';
import '../../../dashboard/presentation/pages/dashboard_screen.dart';
import '../../../guard_duty/presentation/pages/guard_duty_screen.dart';
import '../../../nominal_roll/presentation/pages/nominal_roll_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    NominalRollPage(),
    DashboardScreen(),
    ConductTrackerScreen(),
    GuardDutyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 15.h),
          child: GNav(
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            gap: 7,
            backgroundColor: Theme.of(context).colorScheme.surface,
            color: Colors.deepPurple.shade300,
            activeColor: Colors.white,
            tabBackgroundGradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 72, 30, 229),
                Color.fromARGB(255, 130, 60, 229),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            padding: EdgeInsets.all(16.sp),
            tabs: [
              GButton(
                icon: Icons.people,
                text: 'Nominal Roll',
                textStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GButton(
                icon: Icons.dashboard,
                text: 'Dashboard',
                textStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GButton(
                icon: Icons.track_changes_rounded,
                text: 'Conducts',
                textStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GButton(
                icon: Icons.security,
                text: 'Guard Duty',
                textStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}