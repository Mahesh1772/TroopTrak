import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/text_style.dart';
import 'package:prototype_1/dashboard_screen.dart';

class GNavMainScreen extends StatefulWidget {
  const GNavMainScreen({super.key});

  @override
  State<GNavMainScreen> createState() {
    return _GNavMainScreen();
  }
}

class _GNavMainScreen extends State<GNavMainScreen> {
  int selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    StyledText('Conduct Tracker', 25),
    StyledText('Parade State', 25),
    StyledText('Guard Duty', 25),
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
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
            child: GNav(
                onTabChange: (value) {
                  itemTapped(value);
                },
                gap: 7,
                backgroundColor: Colors.black,
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
                      text: 'Conduct Tracker',
                      textStyle: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  GButton(
                      icon: Icons.perm_contact_calendar_rounded,
                      text: 'Parade State',
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
