// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';

class AddNewStatusScreen extends StatefulWidget {
  AddNewStatusScreen({
    super.key,
    required this.docID,
    required this.selectedStatusType,
    required this.statusName,
    required this.startDate,
    required this.endDate,
    required this.isToggled,
  });

  late TextEditingController statusName;
  late String? selectedStatusType;
  late String startDate;
  late String endDate;
  late String docID;
  final bool isToggled;

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: (Theme.of(context).colorScheme.background ==
                    const Color.fromARGB(255, 243, 246, 254))
                ? ColorScheme.highContrastLight(
                    primary:
                        const Color.fromARGB(255, 129, 71, 230), // <-- SEE HERE
                    onPrimary: Colors.white, // <-- SEE HERE
                    onSurface:
                        Theme.of(context).colorScheme.tertiary, // <-- SEE HERE
                  )
                : ColorScheme.highContrastDark(
                    primary:
                        const Color.fromARGB(255, 129, 71, 230), // <-- SEE HERE
                    onPrimary: Colors.white, // <-- SEE HERE
                    onSurface:
                        Theme.of(context).colorScheme.tertiary, // <-- SEE HERE
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.tertiary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: (Theme.of(context).colorScheme.background ==
                    const Color.fromARGB(255, 243, 246, 254))
                ? ColorScheme.highContrastLight(
                    primary:
                        const Color.fromARGB(255, 129, 71, 230), // <-- SEE HERE
                    onPrimary: Colors.white, // <-- SEE HERE
                    onSurface:
                        Theme.of(context).colorScheme.tertiary, // <-- SEE HERE
                  )
                : ColorScheme.highContrastDark(
                    primary:
                        const Color.fromARGB(255, 129, 71, 230), // <-- SEE HERE
                    onPrimary: Colors.white, // <-- SEE HERE
                    onSurface:
                        Theme.of(context).colorScheme.tertiary, // <-- SEE HERE
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Theme.of(context).colorScheme.tertiary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
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
    DateTime end = DateFormat("d MMM yyyy").parse(widget.endDate);
    DateTime start = DateFormat("d MMM yyyy").parse(widget.startDate);
    start = DateTime(
        start.year, start.month, start.day, start.hour, start.minute + 30);
    end = DateTime(end.year, end.month, end.day, 22, 0, 0);
    if (widget.selectedStatusType != 'Excuse') {
      await addAttendanceDetails(false, start);
      await addAttendanceDetails(true, end);
    }
    db.doc(widget.docID).collection('Statuses').add({
      //User map formatting
      'statusName': widget.statusName.text.trim(),
      'statusType': widget.selectedStatusType,
      'startDate': widget.startDate,
      'endDate': widget.endDate,
      'start_id': DateFormat('yyyy-MM-dd HH:mm:ss').format(start),
      'end_id': DateFormat('yyyy-MM-dd HH:mm:ss').format(end),
    });
    Navigator.pop(context);
  }

  Future addAttendanceDetails(bool i, DateTime date) async {
    db
        .doc(widget.docID)
        .collection('Attendance')
        .doc(DateFormat('yyyy-MM-dd HH:mm:ss').format(date))
        .set({
      //User map formatting
      'isInsideCamp': i,
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(date),
    });
  }

  void display() {
    //print(widget.statusName.text.trim());
    //print(widget.selectedStatusType);
    //print(widget.startDate);
    //print(widget.endDate);
    //print(widget.docID);
  }

  @override
  void dispose() {
    widget.statusName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isToggled ? Colors.white : Colors.black;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: widget.isToggled
          ? const Color.fromARGB(255, 21, 25, 34)
          : const Color.fromARGB(255, 243, 246, 254),
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
                      color: textColor,
                      size: 25.sp,
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    "Let's add a new status for this soldier ✍️",
                    style: GoogleFonts.poppins(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "Fill in the details of the status",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w300,
                      color: textColor,
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  //Status type drop down menu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      border: Border.all(color: textColor),
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
                      border: Border.all(color: textColor),
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
                          border: Border.all(color: textColor),
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
                          child: Icon(
                            Icons.date_range_rounded,
                            color: textColor,
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
                          border: Border.all(color: textColor),
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
                          child: Icon(
                            Icons.date_range_rounded,
                            color: textColor,
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
