// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recase/recase.dart';

class AddNewConductScreen extends StatefulWidget {
  AddNewConductScreen(
      {super.key,
      required this.selectedConductType,
      required this.conductName,
      required this.startDate,
      required this.endDate});

  late TextEditingController conductName;
  late String? selectedConductType;
  late String startDate;
  late String endDate;

  @override
  State<AddNewConductScreen> createState() => _AddNewConductScreenState();
}

class _AddNewConductScreenState extends State<AddNewConductScreen> {
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

  //To store all the names selected for the conduct
  List<String> tempArray = [];

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

  final _conductTypes = [
    "Select conduct...",
    "Run",
    "Route March",
    "IPPT",
    "Outfield",
    "Strength & Power",
    "Metabolic Circuit",
    "Combat Circuit",
    "Live Firing",
  ];

  void _showStartDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.startDate = DateFormat('d MMM yyyy').format(value);
        }
        addUserDetails();
      });
    });
  }

  void _showEndDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.endDate = DateFormat('d MMM yyyy').format(value);
        }
        addUserDetails();
      });
    });
  }

  Future addUserDetails() async {
    await FirebaseFirestore.instance
        .collection('Statuses')
        .doc(widget.conductName.text)
        .update({
      //User map formatting
      'conductName': widget.conductName.text.trim(),
      'conductType': widget.selectedConductType,
      'startDate': widget.startDate,
      'endDate': widget.endDate,
    });
  }

  @override
  void dispose() {
    widget.conductName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.white,
                    size: 25.sp,
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                StyledText(
                  "Add a new conduct for this company ✍️",
                  30.sp,
                  fontWeight: FontWeight.bold,
                ),
                StyledText(
                  "Fill in the details of the conduct",
                  14.sp,
                  fontWeight: FontWeight.w300,
                ),
                SizedBox(
                  height: 40.h,
                ),
                //Status type drop down menu
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: DropdownButtonFormField<String>(
                    alignment: Alignment.center,
                    dropdownColor: Colors.black54,
                    value: widget.selectedConductType,
                    icon: const Icon(
                      Icons.arrow_downward_sharp,
                      color: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black54),
                    items: _conductTypes
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: AutoSizeText(
                              item,
                              maxLines: 1,
                              style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? item) async => setState(() {
                      widget.selectedConductType = item;
                      addUserDetails();
                    }),
                  ),
                ),

                SizedBox(
                  height: 30.h,
                ),

                //Name of status textfield
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: TextField(
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      controller: widget.conductName,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Enter Conduct Name:',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Status start date picker
                    Container(
                      height: 55.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 15.h),
                        child: AutoSizeText(
                          widget.startDate,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 16.sp),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0.sp),
                      child: InkWell(
                        onTap: () {
                          _showStartDatePicker();
                        },
                        child: const Icon(
                          Icons.date_range_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 10.w,
                    ),

                    //Status end date picker
                    Container(
                      width: 145.w,
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 15.h),
                        child: AutoSizeText(
                          widget.endDate,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 16.sp),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0.sp),
                      child: InkWell(
                        onTap: () {
                          _showEndDatePicker();
                        },
                        child: const Icon(
                          Icons.date_range_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.h,
                ),
                const StyledText("Add Participants", 24,
                    fontWeight: FontWeight.bold),
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
                      var docsmapshot = snapshot.data!;
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
                        for (var i = 0; i < users!.length; i++) {
                          documentIDs.add(users[i].reference.id);
                          var data = docsmapshot.docs[i].data()
                              as Map<String, dynamic>;
                          userDetails.add(data);
                        }
                      }
                    }
                    return Flexible(
                      child: SizedBox(
                        height: 300,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: userDetails.length,
                          padding: EdgeInsets.all(12.sp),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (tempArray.contains(
                                      userDetails[index]['name'].toString())) {
                                    tempArray.remove(
                                        userDetails[index]['name'].toString());
                                  } else {
                                    tempArray.add(
                                        userDetails[index]['name'].toString());
                                  }
                                });
                                print(tempArray);
                              },
                              child: Card(
                                color: Colors.black54,
                                child: ListTile(
                                  title: StyledText(
                                      userDetails[index]['name']
                                          .toString()
                                          .titleCase,
                                      16.sp,
                                      fontWeight: FontWeight.w500),
                                  leading: Container(
                                    height: 40.h,
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                      color: tempArray.contains(
                                              userDetails[index]['name']
                                                  .toString())
                                          ? Colors.red
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: StyledText(
                                          tempArray.contains(userDetails[index]
                                                      ['name']
                                                  .toString())
                                              ? "REMOVE"
                                              : "ADD",
                                          18.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 30.h,
                ),
                GestureDetector(
                  onTap: addUserDetails,
                  child: Container(
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      //color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_to_photos_rounded,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          AutoSizeText(
                            'ADD NEW CONDUCT',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
