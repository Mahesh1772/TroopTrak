import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prototype_1/screens/add_new_conduct_screen.dart';
import 'package:prototype_1/screens/user_profile_screen.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';

class ConductTrackerScreen extends StatefulWidget {
  const ConductTrackerScreen({super.key});

  @override
  State<ConductTrackerScreen> createState() => _ConductTrackerScreenState();
}

class _ConductTrackerScreenState extends State<ConductTrackerScreen> {
  // The DocID or the name of the current user is saved in here
  final name = FirebaseAuth.instance.currentUser!.displayName.toString();

  Map<String, dynamic> currentUserData = {};

  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> documentStream;

  Future getCurrentUserData() async {
    var data = FirebaseFirestore.instance.collection('Users').doc(name);
    data.get().then((DocumentSnapshot doc) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewConductScreen(
                selectedConductType: "Select conduct...",
                conductName: TextEditingController(),
                startDate: "Start Date:",
                endDate: "End Date:",
              ),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                  child: StyledText(
                    'Conduct Tracker',
                    26.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25.0.w),
                  child: InkWell(
                    onTap: () {
                      //FirebaseAuth.instance.signOut();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black54,
                              offset: Offset(10.0.w, 10.0.h),
                              blurRadius: 2.0.r,
                              spreadRadius: 2.0.r),
                        ],
                        color: Colors.deepPurple.shade400,
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(defaultPadding.sp),
                        child: Icon(
                          Icons.exit_to_app_rounded,
                          color: Colors.white,
                          size: 35.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          soldierName: currentUserData['name'],
                          soldierRank:
                              "lib/assets/army-ranks/${currentUserData['rank'].toString().toLowerCase()}.png",
                          soldierAppointment: currentUserData['appointment'],
                          company: currentUserData['company'],
                          platoon: currentUserData['platoon'],
                          section: currentUserData['section'],
                          dateOfBirth: currentUserData['dob'],
                          rationType: currentUserData['rationType'],
                          bloodType: currentUserData['bloodgroup'],
                          enlistmentDate: currentUserData['enlistment'],
                          ordDate: currentUserData['ord'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12.0.sp),
                    child: Image.asset(
                      'lib/assets/user.png',
                      width: 50.w,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
