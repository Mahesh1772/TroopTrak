// ignore_for_file: must_be_immutable
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/detailed_screen/tabs/user_profile_tabs/user_profile_screen.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/nominal_roll_screen/qr_code_scanner_page.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/screens/nominal_roll_screen/util/solider_tile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

class NominalRollNewScreen extends StatefulWidget {
  const NominalRollNewScreen({super.key});

  @override
  State<NominalRollNewScreen> createState() => _NominalRollNewScreenState();
}

// List to store all user data, whilst also mapping to name
List<Map<String, dynamic>> userDetails = [];

class _NominalRollNewScreenState extends State<NominalRollNewScreen> {
  // The DocID or the name of the current user is saved in here
  final name = FirebaseAuth.instance.currentUser!.displayName.toString();

  Map<String, dynamic> currentUserData = {};

  //This is what the stream builder is waiting for
  late Stream<QuerySnapshot> documentStream;

  // The list of all document IDs,
  //which have access to each their own personal information
  List<String> documentIDs = [];

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
    isSelectedList[0] = true;
    super.initState();
  }

  List<String> categories = [
    'Name',
    'Rank',
    'Company',
    'Section',
    'Platoon',
    'Ration',
    'Blood',
    'Appointment',
  ];

  List<bool> isSelectedList =
      List.filled(8, false); // Initialize the list with all false values
  String selectedCategory = 'name';
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserData>(context);
    final searchChip = userModel.categorySelected;
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return const QrCodeScannerPage();
                },
                backgroundColor: Colors.transparent,
                isScrollControlled: true);
          },
          child: const Icon(Icons.add),
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, //const Color.fromARGB(255, 254, 251, 234),//const Color.fromARGB(255, 21, 25, 34),
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
                      26.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            soldierName: currentUserData['name'],
                            soldierRank: currentUserData['rank']
                                .toString()
                                .toLowerCase(),
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
                height: 20.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: StyledText(
                  'Our Family of Soldiers:',
                  30.sp,
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
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                    focusColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.search_sharp,
                      color: Colors.white,
                    ),
                    prefixIconColor: Colors.white,
                    fillColor: const Color.fromARGB(255, 72, 30, 229),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none),
                  ),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.all(5),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                      spacing: 10,
                      children: categories
                          .asMap()
                          .entries
                          .map(
                            (category) => ChoiceChip(
                              selected: isSelectedList[category.key],
                              label: Text(category.value),
                              onSelected: (selected) {
                                setState(() {
                                  isSelectedList = List.filled(
                                      categories.length,
                                      false); // Reset all values to false
                                  isSelectedList[category.key] =
                                      selected; // Set the selected value to true for the chosen category
                                  selectedCategory =
                                      searchChip[category.value]!;
                                  print(selectedCategory);
                                });
                              },
                              selectedColor:
                                  const Color.fromARGB(255, 198, 103, 214),
                              backgroundColor: Colors.white,
                            ),
                          )
                          .toList()),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: userModel.data,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    documentIDs = [];
                    userDetails = [];
                    var users = snapshot.data?.docs.toList();
                    if (searchText.isNotEmpty) {
                      users = users!.where((element) {
                        return element
                            .get(selectedCategory)
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
                          isInsideCamp: false,
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
