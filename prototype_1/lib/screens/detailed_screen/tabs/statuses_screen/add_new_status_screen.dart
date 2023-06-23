// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';

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

List<String> suggestions = [
  'LD',
  'RIB (Rest in Bunk)',
  'Ex RMJ ',
  'Ex Heavy Loads',
  'Ex Upper Limb',
  'Ex Lower Limb',
  'Ex Boots',
  'Ex Shoes',
  'Ex Physical Training',
  'Ex Field Training',
  'Ex Outfield',
  'Ex Dust and Smoke',
  'Ex FLEGs',
  'Ex Stay-In',
  'Ex Dog/K9',
  'Ex Uniform',
  'Ex Prolonged Standing/Proning/Squatting/Sitting/Cross-Legged Sitting',
  'Ex High Temperature/High Humidity',
  'Ex Pushup',
  'Ex Situp',
  'Ex Sunlight',
  'Ex grass',
];

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
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.startDate = DateFormat('d MMM yyyy').format(value);
          sDate = DateFormat('d MMM yyyy').format(value);
        }
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
          eDate = DateFormat('d MMM yyyy').format(value);
        }
      });
    });
  }

  Future addUserStatus() async {
    widget.statusName = sName;
    widget.selectedStatusType = sType;
    widget.endDate = eDate;
    widget.startDate = sDate;
    db.doc(widget.docID).collection('Statuses').add({
      //User map formatting
      'statusName': widget.statusName.text.trim(), //sName.text.trim(),
      'statusType': widget.selectedStatusType, //sType,
      'startDate': widget.startDate, //sDate,
      'endDate': widget.endDate, //eDate,
    });
    Navigator.pop(context);
  }

  void display() {
    print(widget.statusName.text.trim());
    print(widget.selectedStatusType);
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
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
                      value: widget.selectedStatusType,
                      //"Select status type...",
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
                        sType = item!;
                      }),
                      validator: (value) {
                        if (value == "Select status type...") {
                          return 'Bruh select Dei!';
                        }
                        return null;
                      },
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
                      child: EasyAutocomplete(
                        suggestions: suggestions,
                        suggestionBuilder: (data) {
                          return Container(
                            margin: const EdgeInsets.all(1),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              data,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Oi can enter the status type please?";
                          }
                          return null;
                        },
                        inputTextStyle: GoogleFonts.poppins(
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
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        IconSnackBar.show(
                            duration: const Duration(seconds: 1),
                            direction: DismissDirection.horizontal,
                            context: context,
                            snackBarType: SnackBarType.save,
                            label: 'Status added successfully!',
                            snackBarStyle: const SnackBarStyle() // this one
                            );
                        addUserStatus();
                      } else {
                        IconSnackBar.show(
                            direction: DismissDirection.horizontal,
                            context: context,
                            snackBarType: SnackBarType.alert,
                            label: 'Details missing',
                            snackBarStyle: const SnackBarStyle() // this one
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
