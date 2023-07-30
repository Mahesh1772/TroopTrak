// ignore_for_file: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String name = FirebaseAuth.instance.currentUser!.displayName!;

class UpdateCurrentUserDetailsPage extends StatefulWidget {
  UpdateCurrentUserDetailsPage({
    super.key,
    required this.name,
    required this.company,
    required this.platoon,
    required this.section,
    required this.appointment,
    required this.dob,
    required this.ord,
    required this.enlistment,
    required this.selectedItem,
    required this.selectedRank,
    required this.selectedBloodType,
    required this.docID,
    required this.callback,
  });

  late TextEditingController name;
  late TextEditingController company;
  late TextEditingController platoon;
  late TextEditingController section;
  late TextEditingController appointment;
  late String dob;
  late String docID;
  late String ord;
  late String enlistment;
  late String? selectedItem;
  late String? selectedRank;
  late String? selectedBloodType;
  late Function callback;

  @override
  State<UpdateCurrentUserDetailsPage> createState() =>
      _UpdateCurrentUserDetailsPageState();
}

class _UpdateCurrentUserDetailsPageState
    extends State<UpdateCurrentUserDetailsPage> {
  bool isFirstTIme = true;
  TextEditingController _name = TextEditingController();
  TextEditingController _company = TextEditingController();
  TextEditingController _platoon = TextEditingController();
  TextEditingController _section = TextEditingController();
  TextEditingController _appointment = TextEditingController();
  String _dob = '';
  String _ord = '';
  String _enlistment = '';
  String _selectedItem = '';
  String _selectedRank = '';
  String _selectedBloodType = '';

  Future goBackWithoutChanges() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(name)
        .update({
      //User map formatting
      'rank': _selectedRank,
      'name': _name,
      'company': _company,
      'platoon': _platoon,
      'section': _section,
      'appointment': _appointment,
      'rationType': _selectedItem,
      'bloodgroup': _selectedBloodType,
      'dob': _dob,
      'ord': _ord,
      'enlistment': _enlistment,
    });
  }

  @override
  void initState() {
    if (isFirstTIme) {
      _name = widget.name;
      _company = widget.company;
      _platoon = widget.platoon;
      _section = widget.section;
      _appointment = widget.appointment;
      _dob = widget.dob;
      _ord = widget.ord;
      _enlistment = widget.enlistment;
      _selectedItem = widget.selectedItem!;
      _selectedRank = widget.selectedRank!;
      _selectedBloodType = widget.selectedBloodType!;
    }
    super.initState();
  }

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
    "3SG",
    "2SG",
    "1SG",
    "SSG",
    "MSG",
    "3WO",
    "2WO",
    "1WO",
    "MWO",
    "SWO",
    "CWO",
    "OCT",
    "2LT",
    "LTA",
    "CPT",
    "MAJ",
    "LTC",
    "SLTC",
    "COL",
    "BG",
    "MG",
    "LG",
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

  void _showDatePicker() async {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(widget.dob),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() async {
        if (value != null) {
          widget.dob = DateFormat('d MMM yyyy').format(value);
        }
        isFirstTIme = false;
        //await addUserDetails();
      });
    });
  }

  void _ordDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(widget.ord),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() async {
        if (value != null) {
          widget.ord = DateFormat('d MMM yyyy').format(value);
        }
        isFirstTIme = false;
        //await addUserDetails();
      });
    });
  }

  void _enlistmentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(widget.enlistment),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() async {
        if (value != null) {
          widget.enlistment = DateFormat('d MMM yyyy').format(value);
        }
        isFirstTIme = false;
        //await addUserDetails();
      });
    });
  }

  Future updateUserDetails() async {
    await addUserDetails();
    widget.callback;
    Navigator.pop(context);
  }

  Future addUserDetails() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(name)
        .set({
      //User map formatting
      'rank': widget.selectedRank,
      'name': _name.text.trim(), //widget.name.text.trim(),
      'company': _company.text.trim(), //widget.company.text.trim(),
      'platoon': _platoon.text.trim(), //widget.platoon.text.trim(),
      'section': _section.text.trim(), //widget.section.text.trim(),
      'appointment': _appointment.text.trim(), //widget.appointment.text.trim(),
      'rationType': widget.selectedItem,
      'bloodgroup': widget.selectedBloodType,
      'dob': widget.dob,
      'ord': widget.ord,
      'enlistment': widget.enlistment,
    }, SetOptions(merge: true));
  }

  void resetControllers() {
    widget.name.clear();
    widget.company.clear();
    widget.platoon.clear();
    widget.section.clear();
    widget.appointment.clear();
    super.dispose();
  }

  @override
  Widget build(context) {
    print(name);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    //await goBackWithoutChanges();
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
                  "Change details  ✍️",
                  30.sp,
                  fontWeight: FontWeight.bold,
                ),
                StyledText(
                  "Update the details of an existing soldier.",
                  14.sp,
                  fontWeight: FontWeight.w300,
                ),

                SizedBox(
                  height: 20.h,
                ),

                //Name of soldier textfield
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: TextField(
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      controller: _name,
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
                SizedBox(height: 10.h),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: AutoSizeText(
                                widget.dob,
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
                          value: widget.selectedItem,
                          icon: const Icon(
                            Icons.arrow_downward_sharp,
                            color: Colors.white,
                          ),
                          style: GoogleFonts.poppins(color: Colors.black54),
                          items: _rationTypes
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0.w),
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
                            widget.selectedItem = item;
                            isFirstTIme = false;
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
                          alignment: Alignment.center,
                          dropdownColor: Colors.black54,
                          value: widget.selectedRank, //?? data['rank']!,
                          icon: const Icon(
                            Icons.arrow_downward_sharp,
                            color: Colors.white,
                          ),
                          style: const TextStyle(color: Colors.black54),
                          items: _ranks
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: AutoSizeText(
                                    item,
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (String? item) async => setState(() {
                            widget.selectedRank = item;
                            isFirstTIme = false;
                            //addUserDetails();
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
                          dropdownColor: Colors.black54,
                          alignment: Alignment.center,
                          value:
                              widget.selectedBloodType,
                          icon: const Icon(
                            Icons.water_drop_sharp,
                            color: Colors.red,
                          ),
                          style: const TextStyle(color: Colors.black54),
                          items: _bloodTypes
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: AutoSizeText(
                                    item,
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (item) async => setState(() {
                            widget.selectedBloodType = item;
                            isFirstTIme = false;
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
                    child: TextField(
                      controller: _company,
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
                    child: TextField(
                      controller: _platoon,
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
                    child: TextField(
                      controller: _section,
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
                    padding: EdgeInsets.only(left: 20.w),
                    child: TextField(
                      controller: _appointment,
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
                SizedBox(height: 20.h),

                //Enlistment Date picker
                Row(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: AutoSizeText(
                                widget.enlistment,
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
                      width: 20.w,
                    ),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: AutoSizeText(
                                widget.ord,
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
                  ],
                ),

                SizedBox(
                  height: 30.h,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 5.0.w),
                      child: GestureDetector(
                        onTap: () async {
                          await updateUserDetails();
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.sp),
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
                              children: [
                                Icon(
                                  Icons.edit_note_rounded,
                                  color: Colors.white,
                                  size: 30.sp,
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                AutoSizeText(
                                  'UPDATE DETAILS',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 30.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
