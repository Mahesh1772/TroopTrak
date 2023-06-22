import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/conduct_tracker_screen/conduct_tracker_screen.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/guard_duty_tracker_screen.dart';
import 'package:prototype_1/screens/dashboard_screen/dashboard_screen.dart';
import 'package:prototype_1/screens/nominal_roll_screen/nominal_roll_screen_new.dart';

class GNavMainScreen extends StatefulWidget {
  const GNavMainScreen({super.key});

  @override
  State<GNavMainScreen> createState() {
    return _GNavMainScreen();
  }
}

class _GNavMainScreen extends State<GNavMainScreen> {
  int selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const NominalRollNewScreen(),
    const ConductTrackerScreen(),
    const GuardDutyTrackerScreen(),
    //const StyledText('Conduct Tracker', 25),
    //const StyledText('Parade State', 25),
  ];
  void itemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 21, 25, 34),
        body: Center(
          child: _widgetOptions.elementAt(selectedIndex),
        ),
        bottomNavigationBar: Container(
          color: const Color.fromARGB(255, 11, 13, 17),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 15.h),
            child: GNav(
                onTabChange: (value) {
                  itemTapped(value);
                },
                gap: 7,
                backgroundColor: const Color.fromARGB(255, 11, 13, 17),
                color: Colors.deepPurple.shade300,
                activeColor: Colors.white,
                tabBackgroundGradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade600,
                    Colors.deepPurple.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                padding: EdgeInsets.all(16.sp),
                tabs: [
                  GButton(
                    icon: Icons.home_outlined,
                    text: 'Home',
                    textStyle: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  GButton(
                      icon: Icons.perm_contact_calendar_rounded,
                      text: 'Nominal Roll',
                      textStyle: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  GButton(
                      icon: Icons.track_changes_rounded,
                      text: 'Conduct Tracker',
                      textStyle: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  GButton(
                      icon: Icons.safety_check,
                      text: 'Guard Duty',
                      textStyle: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
          ),
        ),
      ),
    );
  }
}
