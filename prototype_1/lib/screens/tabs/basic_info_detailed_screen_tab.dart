import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prototype_1/screens/update_soldier_details_screen.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import '../../util/text_styles/soldier_detailed_screen_info_template.dart';
import 'package:firebase_auth/firebase_auth.dart';

var fname = FirebaseAuth.instance.currentUser!.displayName.toString();
var id = FirebaseAuth.instance.currentUser!;

class BasicInfoTab extends StatefulWidget {
   const BasicInfoTab({super.key, required this.docID});

  final String docID;

  @override
  State<BasicInfoTab> createState() => _BasicInfoTabState();
}

class _BasicInfoTabState extends State<BasicInfoTab> {
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

    return SizedBox(
      height: 600.h,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            //.where('name')
            .doc(widget.docID)
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
                  height: 10.h,
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
