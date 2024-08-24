import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/util/soldier_detailed_screen_info_template.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../update_current_user_details.dart';

var fname = FirebaseAuth.instance.currentUser!.displayName.toString();
//var id = FirebaseAuth.instance.currentUser!;

// ignore: must_be_immutable
class UserProfileBasicInfoTab extends StatefulWidget {
  final String dateOfBirth;
  final String rationType;
  final String bloodType;
  final String enlistmentDate;
  final String ordDate;
  final String docID;
  late Function callback;
  late Function deletion;
  final bool isToggled;

  UserProfileBasicInfoTab({
    super.key,
    required this.dateOfBirth,
    required this.rationType,
    required this.bloodType,
    required this.enlistmentDate,
    required this.docID,
    required this.ordDate,
    required this.callback,
    required this.isToggled,
    required this.deletion,
  });

  @override
  State<UserProfileBasicInfoTab> createState() =>
      _UserProfileBasicInfoTabState();
}

class _UserProfileBasicInfoTabState extends State<UserProfileBasicInfoTab>
    with TickerProviderStateMixin {
  _storeOnBoardInfo(int isViewed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
  }

  Future deleteUserAccount() async {
    await deleteAttendance();
    await deleteStatuses();
    await deleteCurrentUser();

    User? id = await FirebaseAuth.instance.currentUser;
    await id!.delete().then((value) => widget.deletion);
  }

  Future deleteStatuses() async {
    var collection = FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.docID)
        .collection('Statuses');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future deleteAttendance() async {
    var collection = FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.docID)
        .collection('Attendance');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future deleteCurrentUser() async {
    await FirebaseFirestore.instance.collection("Users").doc(fname).delete();
  }

  @override
  Widget build(BuildContext context) {
    final userDetailsModel = Provider.of<UserData>(context);
    return SingleChildScrollView(
      child: SizedBox(
        height: 750.h,
        child: StreamBuilder(
          stream: userDetailsModel.userData_data(widget.docID),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //We are trying to map the key and values pairs
              //to a variable called "data" of Type Map
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                children: [
                  SoldierDetailedInfoTemplate(
                    title: "Date Of Birth",
                    content: data['dob'].toString().toUpperCase(),
                    icon: Icons.cake_rounded,
                    isToggled: widget.isToggled,
                  ),
                  SoldierDetailedInfoTemplate(
                    title: "Ration Type:",
                    content: data['rationType'].toUpperCase(),
                    icon: Icons.food_bank_rounded,
                    isToggled: widget.isToggled,
                  ),
                  SoldierDetailedInfoTemplate(
                    title: "Blood Type:",
                    content: data['bloodgroup'].toString(),
                    icon: Icons.bloodtype_rounded,
                    isToggled: widget.isToggled,
                  ),
                  SoldierDetailedInfoTemplate(
                    title: "Enlistment Date:",
                    content: data['enlistment'].toString().toUpperCase(),
                    icon: Icons.date_range_rounded,
                    isToggled: widget.isToggled,
                  ),
                  SoldierDetailedInfoTemplate(
                    title: "ORD:",
                    content: data['ord'].toString().toUpperCase(),
                    icon: Icons.military_tech_rounded,
                    isToggled: widget.isToggled,
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateCurrentUserDetailsPage(
                              callback: widget.callback,
                              docID: widget.docID,
                              name: TextEditingController(text: data['name']),
                              company:
                                  TextEditingController(text: data['company']),
                              platoon:
                                  TextEditingController(text: data['platoon']),
                              section:
                                  TextEditingController(text: data['section']),
                              appointment: TextEditingController(
                                  text: data['appointment']),
                              dob: data['dob'],
                              ord: data['ord'],
                              enlistment: data['enlistment'],
                              selectedItem: data['rationType'],
                              selectedRank: data['rank'],
                              selectedBloodType: data['bloodgroup'],
                              isToggled: widget.isToggled,
                            ),
                          ),
                        ).then((value) => widget.callback);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.0.w, vertical: 16.0.h),
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 72, 30, 229),
                                Color.fromARGB(255, 130, 60, 229),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50.0.r)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_document,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Text(
                              "EDIT SOLDIER DETAILS",
                              style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await deleteUserAccount();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0.w, vertical: 16.0.h),
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            gradient: const LinearGradient(
                              colors: [
                                Colors.red,
                                Color.fromARGB(255, 237, 131, 124)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50.0.r)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Text(
                              "DELETE SOLDIER DETAILS",
                              style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              height: 30.h,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Text('Loading......');
          },
        ),
      ),
    );
  }
}
