// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/conduct_tracker_screen/conduct_tracker_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/guard_duty_tracker_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/dashboard_screen/dashboard_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/nominal_roll_screen/nominal_roll_screen_new.dart';

class GNavMainScreen extends StatefulWidget {
  GNavMainScreen({super.key, this.selectedIndex = 0});

  int selectedIndex;

  @override
  State<GNavMainScreen> createState() {
    return _GNavMainScreen();
  }
}

class _GNavMainScreen extends State<GNavMainScreen> {
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
      widget.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 21, 25, 34),
        body: Center(
          child: _widgetOptions.elementAt(widget.selectedIndex),
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
                    const Color.fromARGB(255, 72, 30, 229),
                    Colors.deepPurple.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                padding: EdgeInsets.all(16.sp),
                tabs: [
                  GButton(
                    key: const Key("home"),
                    icon: Icons.home_outlined,
                    text: 'Home',
                    textStyle: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  GButton(
                      key: const Key("nominalRoll"),
                      icon: Icons.perm_contact_calendar_rounded,
                      text: 'Nominal Roll',
                      textStyle: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  GButton(
                      key: const Key("conductTracker"),
                      icon: Icons.track_changes_rounded,
                      text: 'Conduct Tracker',
                      textStyle: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  GButton(
                      key: const Key("guardDuty"),
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
