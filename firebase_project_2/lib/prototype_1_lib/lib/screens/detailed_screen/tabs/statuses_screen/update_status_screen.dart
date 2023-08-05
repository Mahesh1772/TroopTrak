// ignore_for_file: must_be_immutable
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/util/text_styles/text_style.dart';
import 'package:provider/provider.dart';

import 'package:firebase_project_2/prototype_1_lib/lib/user_models/user_details.dart';

class UpdateStatusScreen extends StatefulWidget {
  UpdateStatusScreen({
    super.key,
    required this.docID,
    required this.selectedStatusType,
    required this.statusName,
    required this.startDate,
    required this.endDate,
    required this.statusID,
  });

  late TextEditingController statusName;
  late String? selectedStatusType;
  late String startDate;
  late String endDate;
  late String docID;
  late String statusID;

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

CollectionReference db = FirebaseFirestore.instance.collection('Users');
TextEditingController sName = TextEditingController();
String _initialsType = '';
String _inititialSDate = '';
String _intitialEDate = '';
String _initialName = '';
Map<String, dynamic> data = {};
String start_date = '';
String end_date = '';

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  bool isFirstTIme = true;
  final _formKey = GlobalKey<FormState>();
  final _statusTypes = [
    "Select status type...",
    "Excuse",
    "Leave",
    "Medical Appointment",
  ];

  @override
  void initState() {
    sName = widget.statusName;
    if (isFirstTIme) {
      _initialName = widget.statusName.text;
      _initialsType = widget.selectedStatusType!;
      _inititialSDate = widget.startDate;
      _intitialEDate = widget.endDate;
    }
    display();
    super.initState();
  }

  void _showStartDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(widget.startDate),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.startDate = DateFormat('d MMM yyyy').format(value);
          isFirstTIme = false;
          editUserStatus();
        }
      });
    });
  }

  void _showEndDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(widget.endDate),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.endDate = DateFormat('d MMM yyyy').format(value);
          editUserStatus();
          isFirstTIme = false;
        }
      });
    });
  }

  void editStatus() async{
    await editUserStatus();
    //isFirstTIme = true;
    Navigator.pop(context);
  }

  Future goBackWithoutChanges() async {
    widget.statusName = sName;
    db.doc(widget.docID).collection('Statuses').doc(widget.statusID).update({
      //User map formatting
      'statusName': _initialName,
      'statusType': _initialsType,
      'startDate': _inititialSDate,
      'endDate': _intitialEDate,
    });
  }

  Future editUserStatus() async {
    widget.statusName = sName;
    db.doc(widget.docID).collection('Statuses').doc(widget.statusID).update({
      //User map formatting
      'statusName': widget.statusName.text.trim(),
      'statusType': widget.selectedStatusType,
      'startDate': widget.startDate,
      'endDate': widget.endDate,
    });
    DateTime end = DateFormat("d MMM yyyy").parse(_intitialEDate);
    DateTime start = DateFormat("d MMM yyyy").parse(_inititialSDate);
    DateTime new_end = DateFormat("d MMM yyyy").parse(widget.endDate);
    DateTime new_start = DateFormat("d MMM yyyy").parse(widget.startDate);
    start = DateTime(
        start.year, start.month, start.day, start.hour, start.minute + 30);
    new_start = DateTime(new_start.year, new_start.month, new_start.day,
        new_start.hour, new_start.minute + 30);
    end = DateTime(end.year, end.month, end.day, 22, 0, 0);
    new_end = DateTime(new_end.year, new_end.month, new_end.day, 22, 0, 0);
    if (widget.selectedStatusType != 'Excuse') {
      await addAttendanceDetails(false, new_start, start);
      await addAttendanceDetails(true, new_end, end);
    } else {
      await deleteAttendanceDetails(
          //DateFormat('yyyy-MM-dd HH:mm:ss').format(start)
          start_date);
      await deleteAttendanceDetails(
          //DateFormat('yyyy-MM-dd HH:mm:ss').format(end)
          end_date);
    }
  }

  Future deleteAttendanceDetails(String attendance_id) async {
    await db
        .doc(widget.docID)
        .collection('Attendance')
        .doc(attendance_id)
        .delete();
  }

  Future addAttendanceDetails(bool i, DateTime date, DateTime docID) async {
    db
        .doc(widget.docID)
        .collection('Attendance')
        .doc(DateFormat('yyyy-MM-dd HH:mm:ss').format(docID))
        .set({
      //User map formatting
      'isInsideCamp': i,
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(date),
    });
  }

  void display() {
    //print(sName.text);
    //print(widget.selectedStatusType);
    //print(widget.startDate);
    //print(widget.endDate);
    //print(widget.docID);
    //print(widget.statusID);
    //print(_inititialSDate);
    //print(_intitialEDate);
  }

  @override
  void dispose() {
    widget.statusName.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userStatusModel = Provider.of<UserData>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: StreamBuilder(
                stream: userStatusModel.updateStatus_data(
                    widget.docID, widget.statusID),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    data = snapshot.data!.data() as Map<String, dynamic>;
                    widget.startDate = data['startDate'];
                    widget.selectedStatusType = data['statusType'];
                    widget.statusName =
                        TextEditingController(text: data['statusName']);
                    widget.endDate = data['endDate'];
                    start_date = data['start_id'];
                    end_date = data['end_id'];
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            goBackWithoutChanges();
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
                            validator: (value) {
                              return null;
                            },
                            dropdownColor: Colors.black54,
                            value: widget.selectedStatusType,
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
                              widget.selectedStatusType = item;
                              isFirstTIme = false;
                              editUserStatus();
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
                              controller: sName,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Status Name',
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
                                  //sDate,
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
                                  //eDate,
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
                          onTap: editStatus,
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
                  );
                }),
          ),
        ),
      ),
    );
  }
}
