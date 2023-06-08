// ignore_for_file: must_be_immutable
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prototype_1/screens/nominal_roll_screen/add_new_soldier_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prototype_1/screens/detailed_screen/tabs/user_profile_tabs/user_profile_screen.dart';
import 'package:prototype_1/util/constants.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:prototype_1/screens/nominal_roll_screen/util/solider_tile.dart';
import 'package:intl/intl.dart';

class NominalRollNewScreen extends StatefulWidget {
  const NominalRollNewScreen({super.key});

  @override
  State<NominalRollNewScreen> createState() => _NominalRollNewScreenState();
}

class _NominalRollNewScreenState extends State<NominalRollNewScreen> {
  // The DocID or the name of the current user is saved in here
  final name = FirebaseAuth.instance.currentUser!.displayName.toString();

  Map<String, dynamic> currentUserData = {};

  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> documentStream;

  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

  // List to store all user data, whilst also mapping to name
  List<Map<String, dynamic>> userDetails = [];

  // To store text being searched
  String searchText = '';

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
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewSoldierPage(
                  name: TextEditingController(),
                  company: TextEditingController(),
                  platoon: TextEditingController(),
                  section: TextEditingController(),
                  appointment: TextEditingController(),
                  dob: DateFormat('d MMM yyyy').format(DateTime.now()),
                  ord: DateFormat('d MMM yyyy').format(DateTime.now()),
                  enlistment: DateFormat('d MMM yyyy').format(DateTime.now()),
                  selectedItem: "Select your ration type...",
                  selectedRank: "Select your rank...",
                  selectedBloodType: "Select your blood type...",
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
                      'Nominal Roll',
                      30.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25.0.w),
                    child: InkWell(
                      onTap: () {
                        print(userDetails);
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
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: StyledText(
                  'Our Family of Soldiers:',
                  20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.all(20.0.sp),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Name',
                    prefixIcon: const Icon(Icons.search_sharp),
                    prefixIconColor: Colors.indigo.shade900,
                    fillColor: Colors.amber,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: documentStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    documentIDs = [];
                    userDetails = [];
                    var users = snapshot.data?.docs.toList();
                    if (searchText.isNotEmpty) {
                      users = users!.where((element) {
                        return element
                            .get('name')
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase());
                      }).toList();
                      for (var user in users) {
                        var data = user.data();
                        userDetails.add(data as Map<String, dynamic>);
                      }
                      if (userDetails.isEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                'No results Found!',
                                style: TextStyle(
                                  color: Colors.purpleAccent,
                                  fontSize: 45.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }
                    } else {
                      for (var user in users!) {
                        var data = user.data();
                        userDetails.add(data as Map<String, dynamic>);
                      }
                    }
                  }
                  return Expanded(
                    child: GridView.builder(
                      itemCount: userDetails.length,
                      padding: EdgeInsets.all(12.sp),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 1.w / 1.5.h),
                      itemBuilder: (context, index) {
                        return SoldierTile(
                          soldierName: userDetails[index]['name'],
                          soldierRank: userDetails[index]['rank'],
                          soldierAppointment: userDetails[index]['appointment'],
                          company: userDetails[index]['company'],
                          platoon: userDetails[index]['platoon'],
                          section: userDetails[index]['section'],
                          dateOfBirth: userDetails[index]['dob'],
                          rationType: userDetails[index]['rationType'],
                          bloodType: userDetails[index]['bloodgroup'],
                          enlistmentDate: userDetails[index]['enlistment'],
                          ordDate: userDetails[index]['ord'],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
