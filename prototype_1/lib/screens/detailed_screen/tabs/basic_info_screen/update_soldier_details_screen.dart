// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateSoldierDetailsPage extends StatefulWidget {
  UpdateSoldierDetailsPage(
      {super.key,
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
      required this.selectedBloodType});

  late TextEditingController name;
  late TextEditingController company;
  late TextEditingController platoon;
  late TextEditingController section;
  late TextEditingController appointment;
  late String dob;
  late String ord;
  late String enlistment;
  late String? selectedItem;
  late String? selectedRank;
  late String? selectedBloodType;

  @override
  State<UpdateSoldierDetailsPage> createState() =>
      _UpdateSoldierDetailsPageState();
}

class _UpdateSoldierDetailsPageState extends State<UpdateSoldierDetailsPage> {
  Future deleteCurrentUser() async {
    FirebaseFirestore.instance.collection("Users").doc(widget.name.text.trim()).delete();
    Navigator.pop(context);
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

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(widget.dob),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.dob = DateFormat('d MMM yyyy').format(value);
        }
        addUserDetails();
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
      setState(() {
        if (value != null) {
          widget.ord = DateFormat('d MMM yyyy').format(value);
        }
        addUserDetails();
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
      setState(() {
        if (value != null) {
          widget.enlistment = DateFormat('d MMM yyyy').format(value);
        }
        addUserDetails();
      });
    });
  }

  Future updateUserDetails() async {
    addUserDetails();
    Navigator.pop(context);
  }

  Future addUserDetails() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.name.text.trim())
        .update({
      //User map formatting
      'rank': widget.selectedRank,
      'name': widget.name.text.trim(),
      'company': widget.company.text.trim(),
      'platoon': widget.platoon.text.trim(),
      'section': widget.section.text.trim(),
      'appointment': widget.appointment.text.trim(),
      'rationType': widget.selectedItem,
      'bloodgroup': widget.selectedBloodType,
      'dob': widget.dob,
      'ord': widget.ord,
      'enlistment': widget.enlistment,
    });
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.name.text.trim())
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //We are trying to map the key and values pairs
                //to a variable called "data" of Type Map
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Column(
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
                            controller: widget.name,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //Date of birth date picker
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: AutoSizeText(
                                widget.dob,
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16.sp),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0.sp),
                            child: InkWell(
                              onTap: () {
                                _showDatePicker();
                              },
                              child: const Icon(
                                Icons.date_range_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          //Ration type dropdown menu
                          Padding(
                            padding: EdgeInsets.only(left: 10.0.w),
                            child: Container(
                              width: 215.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: DropdownButtonFormField<String>(
                                alignment: Alignment.center,
                                dropdownColor: Colors.black54,
                                value: widget.selectedItem,
                                icon: const Icon(
                                  Icons.arrow_downward_sharp,
                                  color: Colors.white,
                                ),
                                style: const TextStyle(color: Colors.black54),
                                items: _rationTypes
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
                                onChanged: (item) => setState(() {
                                  widget.selectedItem = item;
                                  addUserDetails();
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
                        children: [
                          //Rank dropdown menu
                          Padding(
                            padding: EdgeInsets.only(right: 10.0.w),
                            child: Container(
                              width: 165.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: DropdownButtonFormField<String>(
                                alignment: Alignment.center,
                                dropdownColor: Colors.black54,
                                value: widget.selectedRank ?? data['rank']!,
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
                                  addUserDetails();
                                }),
                              ),
                            ),
                          ),

                          //Blood type dropdown menu
                          Padding(
                            padding: EdgeInsets.only(left: 8.0.w),
                            child: Container(
                              width: 200.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: DropdownButtonFormField<String>(
                                dropdownColor: Colors.black54,
                                alignment: Alignment.center,
                                value: widget.selectedBloodType ??
                                    data['bloodgroup']!,
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
                                  addUserDetails();
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
                            controller: widget.company,
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
                            controller: widget.platoon,
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
                            controller: widget.section,
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
                            controller: widget.appointment,
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
                          SizedBox(
                            width: 140.w,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 15.h),
                                child: AutoSizeText(
                                  widget.enlistment,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 16.sp),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0.sp),
                            child: InkWell(
                              onTap: () {
                                _enlistmentDatePicker();
                              },
                              child: const Icon(
                                Icons.date_range_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          SizedBox(
                            width: 20.w,
                          ),
                          //ORD picker
                          SizedBox(
                            width: 140.w,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 15.h),
                                child: AutoSizeText(
                                  widget.ord,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 16.sp),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0.sp),
                            child: InkWell(
                              onTap: () {
                                _ordDatePicker();
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
                        height: 30.h,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 5.0.w),
                            child: GestureDetector(
                              onTap: updateUserDetails,
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                            child: GestureDetector(
                              onTap: deleteCurrentUser,
                              child: Container(
                                padding: EdgeInsets.all(16.sp),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.red,
                                      Color.fromARGB(255, 202, 65, 55)
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
                                        Icons.delete_forever_rounded,
                                        color: Colors.white,
                                        size: 30.sp,
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      AutoSizeText(
                                        'DELETE DETAILS',
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
                    ],
                  ),
                );
              }

              return const Text('Loading......');
            },
          ),
        ),
      ),
    );
  }
}