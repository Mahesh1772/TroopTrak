import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/basic_info_screen/update_soldier_details_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:provider/provider.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/util/soldier_detailed_screen_info_template.dart';

// ignore: must_be_immutable
class BasicInfoTab extends StatefulWidget {
  BasicInfoTab({
    super.key,
    required this.docID,
    required this.callback,
  });

  final String docID;
  late Function callback;

  @override
  State<BasicInfoTab> createState() => _BasicInfoTabState();
}

class _BasicInfoTabState extends State<BasicInfoTab> {
  Future deleteUserAccount() async {
    deleteAttendance();
    deleteStatuses();
    deleteCurrentUser();
    Navigator.pop(context);
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
    FirebaseFirestore.instance.collection("Users").doc(widget.docID).delete();
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
                  ),
                  SoldierDetailedInfoTemplate(
                    title: "Ration Type:",
                    content: data['rationType'].toUpperCase(),
                    icon: Icons.food_bank_rounded,
                  ),
                  SoldierDetailedInfoTemplate(
                    title: "Blood Type:",
                    content: data['bloodgroup'].toString(),
                    icon: Icons.bloodtype_rounded,
                  ),
                  SoldierDetailedInfoTemplate(
                    title: "Enlistment Date:",
                    content: data['enlistment'].toString().toUpperCase(),
                    icon: Icons.date_range_rounded,
                  ),
                  SoldierDetailedInfoTemplate(
                    title: "ORD:",
                    content: data['ord'].toString().toUpperCase(),
                    icon: Icons.military_tech_rounded,
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
                            builder: (context) => UpdateSoldierDetailsPage(
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
                              callback: widget.callback,
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
                            StyledText("EDIT SOLDIER DETAILS", 18.sp,
                                fontWeight: FontWeight.bold),
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
                            StyledText("DELETE SOLDIER DETAILS", 18.sp,
                                fontWeight: FontWeight.bold),
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
