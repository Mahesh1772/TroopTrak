import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/text_style.dart';

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
    StyledText(
      'Home',
    ),
    StyledText(
      'Conduct Tracker',
    ),
    StyledText(
      'Parade State',
    ),
    StyledText(
      'Guard Duty',
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
        appBar: AppBar(
          centerTitle: true,
          title: const Center(child: Text('Home Page')),
          titleTextStyle: GoogleFonts.kanit(
            color: Colors.white,
            fontSize: 30,
            letterSpacing: 0.5,
            wordSpacing: 5,
          ),
          backgroundColor: const Color.fromARGB(255, 105, 59, 233),
          toolbarHeight: 40,
          toolbarOpacity: 1.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
        body: Center(
          child: _widgetOptions.elementAt(selectedIndex),
        ),
        bottomNavigationBar: Container(
          color: const Color.fromARGB(255, 208, 208, 209),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
            child: GNav(
                onTabChange: (value) {
                  itemTapped(value);
                },
                gap: 7,
                backgroundColor: const Color.fromARGB(255, 208, 208, 209),
                color: Colors.pink,
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
                tabs: const [
                  GButton(
                    icon: Icons.home_outlined,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.track_changes_rounded,
                    text: 'Conduct Tracker',
                  ),
                  GButton(
                    icon: Icons.perm_contact_calendar_rounded,
                    text: 'Parade State',
                  ),
                  GButton(
                    icon: Icons.safety_check,
                    text: 'Guard Duty',
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
