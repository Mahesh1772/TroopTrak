import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/screens/detailed_screen/tabs/basic_info_screen/update_soldier_details_screen.dart';
import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:firebase_project_2/screens/detailed_screen/util/soldier_detailed_screen_info_template.dart';

var fname = FirebaseAuth.instance.currentUser!.displayName.toString();
var id = FirebaseAuth.instance.currentUser!;
List profile = [
  "Sivagnanam Maheshwaran",
  "lib/assets/army-ranks/3sg.png",
  Colors.indigo.shade800,
  "IN CAMP",
  "lib/assets/army-ranks/soldier.png",
  "LOGISTICS SPECIALIST",
  "Bravo",
  "1",
  "2",
  "05 Apr 2001",
  "VI",
  "AB+",
  "11 Aug 2019",
  "10 Aug 2021",
];

class UserProfileBasicInfoTab extends StatefulWidget {
  final String dateOfBirth;
  final String rationType;
  final String bloodType;
  final String enlistmentDate;
  final String ordDate;

  const UserProfileBasicInfoTab(
      {super.key,
      required this.dateOfBirth,
      required this.rationType,
      required this.bloodType,
      required this.enlistmentDate,
      required this.ordDate});

  @override
  State<UserProfileBasicInfoTab> createState() =>
      _UserProfileBasicInfoTabState();
}

class _UserProfileBasicInfoTabState extends State<UserProfileBasicInfoTab> {
  Future deleteUserAccount() async {
    deleteCurrentUser();
    id.delete();
    Navigator.pop(context);
  }

  Future deleteCurrentUser() async {
    FirebaseFirestore.instance.collection("Users").doc(fname).delete();
  }

  @override
  Widget build(BuildContext context) {
    const docIDs = 'Lee Kuan Yew';

    return SizedBox(
      height: 750.h,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            //.where('name')
            .doc(docIDs)
            .snapshots(),
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
                              selectedBloodType: data['bloodgroup']),
                        ),
                      );
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
                    onPressed: deleteUserAccount,
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
    );
  }
}
