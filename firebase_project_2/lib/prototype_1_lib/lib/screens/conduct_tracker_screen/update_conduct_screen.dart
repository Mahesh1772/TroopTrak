// ignore_for_file: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';

import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

class UpdateConductScreen extends StatefulWidget {
  UpdateConductScreen({
    super.key,
    required this.selectedConductType,
    required this.conductName,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.nonParticipants,
    required this.conductID,
    required this.callbackFunction,
    required this.participants,
  });

  late TextEditingController conductName;
  late String? selectedConductType;
  late String startDate;
  late String startTime;
  late String endTime;
  late String conductID;
  late List nonParticipants;
  late List participants;
  Function callbackFunction;

  @override
  State<UpdateConductScreen> createState() => _UpdateConductScreenState();
}

// Store all the names in conduct
List<String> tempArray = [];
// List of all names
List<String> documentIDs = [];

class _UpdateConductScreenState extends State<UpdateConductScreen> {
// Name of soldiers not included
  List<dynamic> soldierStatusArray = [];

  // List to store all user data, whilst also mapping to name
  List<Map<String, dynamic>> userDetails = [];

  // Boolean value for checking if it is first time or not
  bool isFirstTIme = true;

  // To store text being searched
  String searchText = '';

  CollectionReference db = FirebaseFirestore.instance.collection('Conducts');
  TextEditingController sName = TextEditingController();
  String _initialsType = '';
  String _inititialSDate = '';
  String _intitialSTime = '';
  String _intitialETime = '';
  String _initialName = '';
  Map<String, dynamic> data = {};

  Future getInitialValues() async {
    if (isFirstTIme) {
      _initialName = widget.conductName.text.trim();
      _initialsType = widget.selectedConductType!;
      _inititialSDate = widget.startDate;
      _intitialETime = widget.endTime;
      _intitialSTime = widget.startTime;
    }
    print('getting initial values');
  }

  void editConduct() async {
    await editConductDetails();
    var listofusers =
        userDetails.where((element) => tempArray.contains(element['name']));
    var nonparts = userDetails
        .removeWhere((element) => listofusers.contains(element['name']));
    widget.callbackFunction(listofusers, nonparts);
    Navigator.pop(context);
  }

  Future goBackWithoutChanges() async {
    //tempArray = [];
    //for (var element in documentIDs) {
    //  if (!widget.nonParticipants.contains(element)) {
    //    tempArray.add(element);
    //  }
    //}
    db.doc(widget.conductID).update({
      //User map formatting
      'conductName': _initialName,
      'conductType': _initialsType,
      'startDate': _inititialSDate,
      'startTime': _intitialSTime,
      'endTime': _intitialETime,
      'participants': widget.participants,
    });
  }

  Future editConductDetails() async {
    db.doc(widget.conductID).update({
      //User map formatting
      'conductName': widget.conductName.text.trim(),
      'conductType': widget.selectedConductType,
      'startDate': widget.startDate,
      'startTime': widget.startTime,
      'endTime': widget.endTime,
      'participants': tempArray,
    });
  }

  @override
  void dispose() {
    widget.conductName.clear();
    super.dispose();
  }

  @override
  void initState() {
    getInitialValues();
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
    "SOC/VOC"
  ];

  void _showStartDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.startDate = DateFormat('d MMM yyyy').format(value);
        }
      });
    });
  }

  void _showStartTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    ).then(
      ((value) {
        setState(
          () {
            if (value != null) {
              DateTime now = DateTime.now();
              DateTime dt = DateTime(
                  now.year, now.month, now.day, value.hour, value.minute);

              widget.startTime = DateFormat.jm().format(dt);
            }
          },
        );
      }),
    );
  }

  void _showEndTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    ).then(
      ((value) {
        setState(
          () {
            if (value != null) {
              DateTime now = DateTime.now();
              DateTime dt = DateTime(
                  now.year, now.month, now.day, value.hour, value.minute);

              widget.endTime = DateFormat.jm().format(dt);
            }
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserData>(context);
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
                  onTap: () async {
                    await goBackWithoutChanges();
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
                  "Edit conduct ✍️",
                  30.sp,
                  fontWeight: FontWeight.bold,
                ),
                StyledText(
                  "Details of the conduct",
                  14.sp,
                  fontWeight: FontWeight.w300,
                ),
                SizedBox(
                  height: 40.h,
                ),
                //Status type drop down menu
                Container(
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
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
                      }),
                    ),
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
                InkWell(
                  onTap: () {
                    _showStartDatePicker();
                  },
                  child: Container(
                    height: 70.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 15.h),
                          child: AutoSizeText(
                            widget.startDate,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 16.sp),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.sp),
                          child: const Icon(
                            Icons.date_range_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        _showStartTimePicker();
                      },
                      child: Container(
                        height: 70.h,
                        width: 200.w,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: AutoSizeText(
                                widget.startTime,
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0.sp),
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    InkWell(
                      onTap: () {
                        _showEndTimePicker();
                      },
                      child: Container(
                        height: 70.h,
                        width: 200.w,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: AutoSizeText(
                                widget.endTime,
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0.sp),
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
                StreamBuilder2<QuerySnapshot,
                    DocumentSnapshot<Map<String, dynamic>>>(
                  streams: StreamTuple2(
                      userModel.data, userModel.conduct_data(widget.conductID)),
                  builder: (context, snapshots) {
                    if (snapshots.snapshot2.hasData) {
                      var conductData = snapshots.snapshot2.data!.data()
                          as Map<String, dynamic>;
                      if (isFirstTIme) {
                        tempArray = List<String>.from(
                            conductData['participants'] as List);
                      }
                    }
                    if (snapshots.snapshot1.hasData) {
                      documentIDs = [];
                      userDetails = [];
                      var users = snapshots.snapshot1.data?.docs.toList();
                      var docsmapshot = snapshots.snapshot1.data!;
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
                          documentIDs.add(user['name']);
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
                          documentIDs.add(users[i]['name']);
                          var data = docsmapshot.docs[i].data()
                              as Map<String, dynamic>;
                          userDetails.add(data);
                        }
                      }
                      //filter();
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
                                  isFirstTIme = false;
                                });
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
                  onTap: editConduct,
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
                            'EDIT CONDUCT DETAILS',
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
