// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';

class AddNewStatusScreen extends StatefulWidget {
  AddNewStatusScreen(
      {super.key,
      required this.docID,
      required this.selectedStatusType,
      required this.statusName,
      required this.startDate,
      required this.endDate});

  late TextEditingController statusName;
  late String? selectedStatusType;
  late String startDate;
  late String endDate;
  late String docID;

  @override
  State<AddNewStatusScreen> createState() => _AddNewStatusScreenState();
}

CollectionReference db = FirebaseFirestore.instance.collection('Users');

class _AddNewStatusScreenState extends State<AddNewStatusScreen> {
  final _formKey = GlobalKey<FormState>();

  final _statusTypes = [
    "Select status type...",
    "Excuse",
    "Leave",
    "Medical Appointment",
  ];

  String sType = '';
  TextEditingController sName = TextEditingController();
  String sDate = DateFormat('d MMM yyyy').format(DateTime.now());
  String eDate = DateFormat('d MMM yyyy').format(DateTime.now());

  void _showStartDatePicker() {
    showDatePicker(
      context: context,
      initialDate:
          DateTime.now(), //DateFormat("d MMM yyyy").parse(widget.startDate),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.startDate = DateFormat('d MMM yyyy').format(value);
          sDate = DateFormat('d MMM yyyy').format(value);
        }
        //addUserStatus();
      });
    });
  }

  void _showEndDatePicker() {
    showDatePicker(
      context: context,
      initialDate:
          DateTime.now(), //DateFormat("d MMM yyyy").parse(widget.endDate),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.endDate = DateFormat('d MMM yyyy').format(value);
          eDate = DateFormat('d MMM yyyy').format(value);
        }
        //addUserStatus();
      });
    });
  }

  Future addUserStatus() async {
    //await FirebaseFirestore.instance
    //    .collection('Users')
    db
        .doc(widget.docID)
        .collection('Statuses')
        //.doc(sName.text.trim())
        .add({
      //User map formatting
      'statusName': sName.text.trim(), //widget.statusName.text.trim(),//
      'statusType': sType, //widget.selectedStatusType,
      'startDate': sDate, //widget.startDate,
      'endDate': eDate, //widget.endDate,
    });
    Navigator.pop(context);
  }

  void display() {
    print(sName.text.trim());
    print(sType);
    print(widget.startDate);
    print(widget.endDate);
    print(widget.docID);
  }

  @override
  void dispose() {
    widget.statusName.dispose();
    super.dispose();
  }

  @override
  void initState() {
    widget.statusName = sName;
    widget.endDate = eDate;
    widget.selectedStatusType = sType;
    widget.startDate = sDate;
  }

  @override
  Widget build(BuildContext context) {

    void initState() {
      widget.statusName = sName;
      widget.endDate = eDate;
      widget.selectedStatusType = sType;
      widget.startDate = sDate;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Form(
              key: _formKey,
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
                    "Let's add a new status for this soldier ✍️",
                    30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  StyledText(
                    "Fill in the details of the status",
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
                      value:
                          "Select status type...", //widget.selectedStatusType,
                      icon: const Icon(
                        Icons.arrow_downward_sharp,
                        color: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black54),
                      items: _statusTypes
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
                        //widget.selectedStatusType = item;
                        sType = item!;
                        //addUserStatus();
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
                      child: TextFormField(
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: sName, //widget.statusName,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Enter Status Name:',
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
                            //widget.startDate,
                            sDate,
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
                            //widget.endDate,
                            eDate,
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

                  GestureDetector(
                    onTap:  addUserStatus,//display, //
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
                              'ADD STATUS',
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
}
