import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/text_style.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() {
    return _MainScreen();
  }
}

class _MainScreen extends State<MainScreen> {
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
          backgroundColor: const Color.fromARGB(255, 75, 26, 211),
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
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
              backgroundColor: Color.fromARGB(255, 53, 19, 154),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_rounded),
              label: 'Conduct Tracker',
              backgroundColor: Color.fromARGB(255, 116, 8, 130),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.perm_contact_calendar_rounded),
              label: 'Parade State',
              backgroundColor: Color.fromARGB(255, 113, 20, 49),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.safety_check),
              label: 'Guard Duty',
              backgroundColor: Color.fromARGB(255, 22, 42, 114),
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.greenAccent,
          onTap: itemTapped,
        ),
      ),
    );
  }
}
