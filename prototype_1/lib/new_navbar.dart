import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/text_style.dart';
import 'package:prototype_1/dashboard_screen.dart';
import 'package:prototype_1/nominal_roll_screen_new.dart';

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
    NominalRollNewScreen(),
    const StyledText(
      'Parade State',
      25,
      fontWeight: FontWeight.w500,
    ),
    //const StyledText('Conduct Tracker', 25),
    //const StyledText('Parade State', 25),
    const StyledText(
      'Guard Duty',
      25,
      fontWeight: FontWeight.w500,
    ),
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
        backgroundColor: const Color.fromARGB(255, 21, 25, 34),
        body: Center(
          child: _widgetOptions.elementAt(selectedIndex),
        ),
        bottomNavigationBar: Container(
          color: const Color.fromARGB(255, 11, 13, 17),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
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
                padding: const EdgeInsets.all(16),
                tabs: [
                  GButton(
                    icon: Icons.home_outlined,
                    text: 'Home',
                    textStyle: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  GButton(
                      icon: Icons.track_changes_rounded,
                      text: 'Nominal Roll',
                      textStyle: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  GButton(
                      icon: Icons.perm_contact_calendar_rounded,
                      text: 'Nominal Roll',
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
