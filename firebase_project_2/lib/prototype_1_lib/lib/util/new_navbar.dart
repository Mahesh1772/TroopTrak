// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/themes/dark_theme.dart';
import 'package:firebase_project_2/themes/light_theme.dart';
import 'package:firebase_project_2/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/conduct_tracker_screen/conduct_tracker_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/guard_duty_tracker_screen.dart/guard_duty_tracker_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/dashboard_screen/dashboard_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/nominal_roll_screen/nominal_roll_screen_new.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/user_profile_tabs/user_profile_screen.dart';

class GNavMainScreen extends StatefulWidget {
  GNavMainScreen({super.key, this.selectedIndex = 0});

  int selectedIndex;

  @override
  State<GNavMainScreen> createState() {
    return _GNavMainScreen();
  }
}

var fname;
var firebase_auth = FirebaseAuth.instance;

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
      displayTitle(index);
    });
  }

  void getDisplayname() async {
    fname = firebase_auth.currentUser!.displayName.toString();
  }

  String displayTitle(int index) {
    String title = "";

    switch (index) {
      case 0:
        title = "Dashboard";
        break;
      case 1:
        title = "Nominal Roll";
        break;
      case 2:
        title = "Conduct Tracker";
        break;
      case 3:
        title = "Guard Duty";
        break;
      default:
        title = "Dashboard";
        break;
    }

    return title;
  }

  ThemeManager _themeManager = ThemeManager();
  bool isToggled = true;

  @override
  Widget build(BuildContext context) {
    getDisplayname();
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themeMode,
      home: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 60.h,
            title: AutoSizeText(
              displayTitle(widget.selectedIndex),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 26.sp,
                  color: (_themeManager.themeMode == ThemeMode.dark)
                      ? Colors.white
                      : Colors.black),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (isToggled) {
                    setState(() {
                      isToggled = false;
                      _themeManager.toggleTheme(isToggled);
                    });
                  } else {
                    setState(() {
                      isToggled = true;
                      _themeManager.toggleTheme(isToggled);
                    });
                  }
                },
                icon: isToggled
                    ? Icon(
                        Icons.dark_mode_rounded,
                        color: Colors.white,
                        size: 30.sp,
                      )
                    : Icon(
                        Icons.light_mode_rounded,
                        color: Colors.orange,
                        size: 30.sp,
                      ),
              ),
              InkWell(
                key: const Key("userProfileIcon"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        isToggled: isToggled,
                        docID: fname,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(12.0.sp),
                  child: Image.asset(
                    'lib/assets/icons8-user-96.png',
                    width: 50.w,
                    color: isToggled ? Colors.white : null,
                  ),
                ),
              ),
            ],
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: (_themeManager.themeMode == ThemeMode.dark)
              ? const Color.fromARGB(255, 21, 25, 34)
              : const Color.fromARGB(255, 243, 246, 254),
          body: Center(
            child: _widgetOptions.elementAt(widget.selectedIndex),
          ),
          bottomNavigationBar: Container(
            color: (_themeManager.themeMode == ThemeMode.dark)
                ? const Color.fromARGB(255, 21, 25, 34)
                : const Color.fromARGB(255, 243, 246, 254),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 15.h),
              child: GNav(
                  onTabChange: (value) {
                    itemTapped(value);
                  },
                  gap: 7.w,
                  backgroundColor: (_themeManager.themeMode == ThemeMode.dark)
                      ? const Color.fromARGB(255, 21, 25, 34)
                      : const Color.fromARGB(255, 243, 246, 254),
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
      ),
    );
  }
}
