// ignore_for_file: must_be_immutable
import 'package:firebase_project_2/phone_authentication/provider/auth_provider.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../util/new_navbar.dart';
import '../util/text_styles/text_style.dart';

class AddNewMen extends StatefulWidget {
  const AddNewMen({super.key});

  @override
  State<AddNewMen> createState() => _AddNewMenState();
}

TextEditingController name = TextEditingController();
TextEditingController company = TextEditingController();
TextEditingController platoon = TextEditingController();
TextEditingController section = TextEditingController();
TextEditingController appointment = TextEditingController();
String dob = 'Date of Birth';
String ord = 'Date of ORD';
String enlistment = 'Enlishment Date';
String? selectedItem = "Select your ration type...";
String? selectedRank = "Select your rank...";
String? selectedBloodType = "Select your blood type...";

class _AddNewMenState extends State<AddNewMen> {
  bool _isNumeric(String str) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
    return numericRegex.hasMatch(str);
  }

  final _formKey = GlobalKey<FormState>();

  final _rationTypes = [
    "Select your ration type...",
    "NM",
    "M",
    "VI",
    "VC",
    "SD NM",
    "SD M",
    "SD VI",
    "SD VC"
  ];

  final _ranks = [
    "Select your rank...",
    "REC",
    "PTE",
    "LCP",
    "CPL",
    "CFC",
    "SCT",
    "OCT",
  ];

  final _bloodTypes = [
    "Select your blood type...",
    "O-",
    "O+",
    "B-",
    "B+",
    "A-",
    "A+",
    "AB-",
    "AB+",
    "Unknown"
  ];

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        if (value != null) {
          dob = DateFormat('d MMM yyyy').format(value);
        }
        //addUserDetails();
      });
    });
  }

  void _ordDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          ord = DateFormat('d MMM yyyy').format(value);
        }
        //addUserDetails();
      });
    });
  }

  void _enlistmentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          enlistment = DateFormat('d MMM yyyy').format(value);
        }
        //addUserDetails();
      });
    });
  }

  Future addAttendanceDetails() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(name.text.trim())
        .collection('Attendance')
        .doc(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()))
        .set({
      //User map formatting
      'isInsideCamp': true,
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(DateTime.now()),
    });
  }

  @override
  void dispose() {
    name.clear();
    company.clear();
    platoon.clear();
    section.clear();
    appointment.clear();
    super.dispose();
  }

  @override
  Widget build(context) {
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: isLoading
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back_sharp,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const StyledText(
                          "Let's get things set up  ✍️",
                          30,
                          fontWeight: FontWeight.bold,
                        ),
                        const StyledText(
                          "Fill in the details of the new soldier you wish to add",
                          14,
                          fontWeight: FontWeight.w300,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Name of soldier textfield
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: TextFormField(
                              validator: (value) {
                                if (value == '') {
                                  return 'Must have a name right';
                                } else if (_isNumeric(value!)) {
                                  return 'Name got number meh';
                                } else if (value.length < 5) {
                                  return 'Brother, enter full name leh';
                                } else {
                                  return null;
                                }
                              },
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              controller: name,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Enter Name (as in NRIC):',
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
                          height: 20.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //Date of birth date picker
                            InkWell(
                              onTap: () {
                                _showDatePicker();
                              },
                              child: Container(
                                height: 70.h,
                                width: 177.w,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w, vertical: 15.h),
                                      child: AutoSizeText(
                                        dob,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16.sp),
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

                            //Ration type dropdown menu
                            Container(
                              height: 70.h,
                              width: 240.w,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == "Select your ration type...") {
                                      return 'Walao what food you eat?';
                                    }
                                    return null;
                                  },
                                  alignment: Alignment.center,
                                  dropdownColor: Colors.black54,
                                  value: selectedItem,
                                  icon: const Icon(
                                    Icons.arrow_downward_sharp,
                                    color: Colors.white,
                                  ),
                                  style: GoogleFonts.poppins(
                                      color: Colors.black54),
                                  items: _rationTypes
                                      .map(
                                        (item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0.w),
                                            child: AutoSizeText(
                                              item,
                                              maxLines: 1,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (item) => setState(() {
                                    selectedItem = item;
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //Rank dropdown menu
                            Container(
                              height: 70.h,
                              width: 185.w,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == "Select your rank...") {
                                      return 'Walao provide rank liao';
                                    }
                                    return null;
                                  },
                                  alignment: Alignment.center,
                                  dropdownColor: Colors.black54,
                                  value: selectedRank,
                                  icon: const Icon(
                                    Icons.arrow_downward_sharp,
                                    color: Colors.white,
                                  ),
                                  style: GoogleFonts.poppins(
                                      color: Colors.black54),
                                  items: _ranks
                                      .map(
                                        (item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0.w),
                                            child: AutoSizeText(
                                              item,
                                              maxLines: 1,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (String? item) async =>
                                      setState(() {
                                    selectedRank = item;
                                  }),
                                ),
                              ),
                            ),

                            //Blood type dropdown menu
                            Container(
                              height: 70.h,
                              width: 235.w,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == "Select your blood type...") {
                                      return 'Why your blood field empty ah?';
                                    }
                                    return null;
                                  },
                                  dropdownColor: Colors.black54,
                                  alignment: Alignment.center,
                                  value: selectedBloodType,
                                  icon: const Icon(
                                    Icons.water_drop_sharp,
                                    color: Colors.red,
                                  ),
                                  style: GoogleFonts.poppins(
                                      color: Colors.black54),
                                  items: _bloodTypes
                                      .map(
                                        (item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0.w),
                                            child: AutoSizeText(
                                              item,
                                              maxLines: 1,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (item) async => setState(() {
                                    selectedBloodType = item;
                                    //addUserDetails();
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),

                        //Company textfield
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: TextFormField(
                              validator: (value) {
                                if (value == '') {
                                  return 'Company Name Missing';
                                }
                                return null;
                              },
                              controller: company,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Company:',
                                labelStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        //Platoon textfield
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: TextFormField(
                              validator: (value) {
                                if (value == '') {
                                  return 'Platoon Information Missing';
                                }
                                return null;
                              },
                              controller: platoon,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Platoon:',
                                labelStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        //Section textfield
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.w),
                            child: TextFormField(
                              validator: (value) {
                                if (value == '') {
                                  return 'Section Information Missing';
                                }
                                return null;
                              },
                              controller: section,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Section:',
                                labelStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        //Soldier Appointment text field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.r),
                            child: TextFormField(
                              validator: (value) {
                                if (value == '') {
                                  return 'Appointment Missing';
                                }
                                return null;
                              },
                              controller: appointment,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Appointment (in unit):',
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
                          height: 20.h,
                        ),

                        //Enlistment Date picker
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                _enlistmentDatePicker();
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w, vertical: 15.h),
                                      child: AutoSizeText(
                                        enlistment,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16.sp),
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

                            //comment

                            //ORD picker
                            InkWell(
                              onTap: () {
                                _ordDatePicker();
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w, vertical: 15.h),
                                      child: AutoSizeText(
                                        ord,
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16.sp),
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
                          ],
                        ),

                        SizedBox(
                          height: 30.h,
                        ),

                        GestureDetector(
                          onTap: () {
                            //print(widget.selectedItem);
                            if (_formKey.currentState!.validate()) {
                              IconSnackBar.show(
                                  duration: const Duration(seconds: 2),
                                  direction: DismissDirection.horizontal,
                                  context: context,
                                  snackBarType: SnackBarType.save,
                                  label: 'Soldier tile created',
                                  snackBarStyle:
                                      const SnackBarStyle() // this one
                                  );
                              storeData();
                            } else {
                              IconSnackBar.show(
                                  direction: DismissDirection.horizontal,
                                  context: context,
                                  snackBarType: SnackBarType.alert,
                                  label: 'Details missing',
                                  snackBarStyle:
                                      const SnackBarStyle() // this one
                                  );
                            }
                          },
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
                                    Icons.group_add_rounded,
                                    color: Colors.white,
                                    size: 30.sp,
                                  ),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  AutoSizeText(
                                    'ADD NEW SOLDIER',
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
            ),
    );
  }

  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap
        .saveUserData(
      context,
      name.text.trim(),
      section.text.trim(),
      platoon.text.trim(),
      company.text.trim(),
      appointment.text.trim(),
      dob,
      ord,
      enlistment,
      selectedItem!,
      selectedBloodType!,
      0,
      selectedRank!,
    )
        .then((value) {
      ap.setSignIn();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const GNavMainScreen(),
        ),
        (route) => false,
      );
    });
  }
}
