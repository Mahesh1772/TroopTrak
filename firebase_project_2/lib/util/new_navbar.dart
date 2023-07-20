import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/screens/detailed_screen/tabs/user_profile_tabs%20copy/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/screens/conduct_tracker_screen/conduct_tracker_screen.dart';
import 'package:firebase_project_2/screens/guard_duty_tracker_screen.dart/guard_duty_tracker_screen.dart';

class GNavMainScreen extends StatefulWidget {
  const GNavMainScreen({super.key});

  @override
  State<GNavMainScreen> createState() {
    return _GNavMainScreen();
  }
}

class _GNavMainScreen extends State<GNavMainScreen> {
  final name = FirebaseAuth.instance.currentUser!.uid.toString();

  String fname = FirebaseAuth.instance.currentUser!.displayName.toString();

  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> documentStream;

  Map<String, dynamic> currentUserData = {};

  Future getCurrentUserData() async {
    var data = FirebaseFirestore.instance.collection('Men').doc(name);
    await data.get().then((DocumentSnapshot doc) {
      currentUserData = doc.data() as Map<String, dynamic>;
      // ...
    });
  }

  @override
  void initState() {
    documentStream = FirebaseFirestore.instance.collection('Users').snapshots();
    getCurrentUserData();
    super.initState();
  }

  int selectedIndex = 0;

  void itemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      const UserProfileScreen(),
      const ConductTrackerScreen(),
      const GuardDutyTrackerScreen(),
    ];

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
                  const Color.fromARGB(255, 72, 30, 229),
                  Colors.deepPurple.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              padding: EdgeInsets.all(16.sp),
              tabs: [
                GButton(
                  icon: Icons.person,
                  text: 'My Profile',
                  textStyle: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
