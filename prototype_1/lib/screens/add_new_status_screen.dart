// // ignore_for_file: must_be_immutable
// ignore_for_file: must_be_immutable
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewStatusPage extends StatefulWidget {
  AddNewStatusPage(
      {super.key,
      required this.docID,
      required this.statusName,
      required this.startDate,
      required this.endDate,
      required this.selectedStatusType});

  late TextEditingController statusName;
  late String docID;
  late String startDate;
  late String endDate;
  late String? selectedStatusType;

  @override
  State<AddNewStatusPage> createState() => _AddNewStatusPageState();
}

class _AddNewStatusPageState extends State<AddNewStatusPage> {
  bool _isNumeric(String str) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
    return numericRegex.hasMatch(str);
  }

  final _formKey = GlobalKey<FormState>();

  final _statusTypes = [
    "Select status type...",
    "Excuse",
    "Leave",
    "Medical Appointment",
  ];

  void _startDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(widget.startDate),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.startDate = DateFormat('d MMM yyyy').format(value);
        }
        //addUserDetails();
      });
    });
  }

  void _endDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(widget.endDate),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          widget.endDate = DateFormat('d MMM yyyy').format(value);
        }
        //addUserDetails();
      });
    });
  }

  Future addUserStatus() async {
    //await FirebaseFirestore.instance
    //    .collection('Users')
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.docID)
        .collection('Statuses')
        //.doc(sName.text.trim())
        .add({
      //User map formatting
      'statusName': widget.statusName.text.trim(),
      'statusType': widget.selectedStatusType,
      'startDate': widget.startDate,
      'endDate': widget.endDate,
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    widget.statusName.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SingleChildScrollView(
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
                    "Add a new status  ✍️",
                    30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  StyledText(
                    "Fill in the details",
                    14.sp,
                    fontWeight: FontWeight.w300,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  //Status type dropdown menu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: DropdownButtonFormField<String>(
                      validator: (value) {
                        if (value == "Select status type...") {
                          return 'Walao what status you have?';
                        }
                        return null;
                      },
                      alignment: Alignment.center,
                      dropdownColor: Colors.black54,
                      value: widget.selectedStatusType,
                      icon: const Icon(
                        Icons.arrow_downward_sharp,
                        color: Colors.white,
                      ),
                      style: GoogleFonts.poppins(color: Colors.black54),
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
                      onChanged: (item) => setState(() {
                        widget.selectedStatusType = item;
                        //addUserDetails();
                      }),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
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
                        validator: (value) {
                          if (value == '') {
                            return 'Must have a name right';
                          } else if (_isNumeric(value!)) {
                            return 'Name got number meh';
                          } else {
                            return null;
                          }
                        },
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        controller: widget.statusName,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Status Name:',
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

                  //Status Start Date picker
                  Row(
                    children: [
                      SizedBox(
                        width: 150.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 15.h),
                            child: Text(
                              widget.startDate,
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
                            _startDatePicker();
                          },
                          child: const Icon(
                            Icons.date_range_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),

                      //Status end date picker
                      SizedBox(
                        width: 150.w,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 15.h),
                            child: Text(
                              widget.endDate,
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
                            _endDatePicker();
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

                  GestureDetector(
                    onTap: () {
                      //print(widget.selectedItem);
                      if (_formKey.currentState!.validate()) {
                        IconSnackBar.show(
                            duration: Duration(seconds: 2),
                            direction: DismissDirection.horizontal,
                            context: context,
                            snackBarType: SnackBarType.save,
                            label: 'Status tile created',
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
                              Icons.group_add_rounded,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            AutoSizeText(
                              'ADD NEW STATUS',
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




































// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:prototype_1/util/text_styles/text_style.dart';

// class AddNewStatusScreen extends StatefulWidget {
//   AddNewStatusScreen(
//       {super.key,
//       required this.docID,
//       required this.selectedStatusType,
//       required this.statusName,
//       required this.startDate,
//       required this.endDate});

//   late TextEditingController statusName;
//   late String? selectedStatusType;
//   late String startDate;
//   late String endDate;
//   late String docID;

//   @override
//   State<AddNewStatusScreen> createState() => _AddNewStatusScreenState();
// }

// //CollectionReference db = FirebaseFirestore.instance.collection('Users');

// class _AddNewStatusScreenState extends State<AddNewStatusScreen> {
//   bool _isNumeric(String str) {
//     final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
//     return numericRegex.hasMatch(str);
//   }

//   final _formKey = GlobalKey<FormState>();

//   final _statusTypes = [
//     "Select status type...",
//     "Excuse",
//     "Leave",
//     "Medical Appointment",
//   ];

//   // String sType = '';
//   // TextEditingController sName = TextEditingController();
//   // String sDate = DateFormat('d MMM yyyy').format(DateTime.now());
//   // String eDate = DateFormat('d MMM yyyy').format(DateTime.now());

//   void _showStartDatePicker() {
//     showDatePicker(
//       context: context,
//       initialDate: DateFormat("d MMM yyyy").parse(widget.startDate),
//       firstDate: DateTime(1960),
//       lastDate: DateTime(2030),
//     ).then((value) {
//       setState(() {
//         if (value != null) {
//           widget.startDate = DateFormat('d MMM yyyy').format(value);
//           //sDate = DateFormat('d MMM yyyy').format(value);
//         }
//         //addUserStatus();
//       });
//     });
//   }

//   void _showEndDatePicker() {
//     showDatePicker(
//       context: context,
//       initialDate: DateFormat("d MMM yyyy").parse(widget.endDate),
//       firstDate: DateTime(1960),
//       lastDate: DateTime(2030),
//     ).then((value) {
//       setState(() {
//         if (value != null) {
//           widget.endDate = DateFormat('d MMM yyyy').format(value);
//           //eDate = DateFormat('d MMM yyyy').format(value);
//         }
//         //addUserStatus();
//       });
//     });
//   }

//   Future addUserStatus() async {
//     //await FirebaseFirestore.instance
//     //    .collection('Users')
//     await FirebaseFirestore.instance
//         .collection('Users')
//         .doc(widget.docID)
//         .collection('Statuses')
//         //.doc(sName.text.trim())
//         .add({
//       //User map formatting
//       'statusName': widget.statusName.text.trim(),
//       'statusType': widget.selectedStatusType,
//       'startDate': widget.startDate,
//       'endDate': widget.endDate,
//     });
//     Navigator.pop(context);
//   }

//   void display() {
//     print(widget.statusName.text.trim());
//     print(widget.selectedStatusType);
//     print(widget.startDate);
//     print(widget.endDate);
//     print(widget.docID);
//   }

//   @override
//   void dispose() {
//     widget.statusName.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // void initState() {
//     //   widget.statusName = sName;
//     //   widget.endDate = eDate;
//     //   widget.selectedStatusType = sType;
//     //   widget.startDate = sDate;
//     // }

//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: const Color.fromARGB(255, 21, 25, 34),
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12.w),
//             child: Form(
//               key: _formKey,
//               autovalidateMode: AutovalidateMode.onUserInteraction,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Icon(
//                       Icons.arrow_back_sharp,
//                       color: Colors.white,
//                       size: 25.sp,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 20.h,
//                   ),
//                   StyledText(
//                     "Let's add a new status for this soldier ✍️",
//                     30.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   StyledText(
//                     "Fill in the details of the status",
//                     14.sp,
//                     fontWeight: FontWeight.w300,
//                   ),
//                   SizedBox(
//                     height: 40.h,
//                   ),
//                   //Status type drop down menu
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       border: Border.all(color: Colors.white),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: DropdownButtonFormField<String>(
//                       validator: (value) {
//                         if (value == "Select status type...") {
//                           return 'Walao what status type you have?';
//                         }
//                         return null;
//                       },
//                       alignment: Alignment.center,
//                       dropdownColor: Colors.black54,
//                       value: widget.selectedStatusType,
//                       icon: const Icon(
//                         Icons.arrow_downward_sharp,
//                         color: Colors.white,
//                       ),
//                       style: GoogleFonts.poppins(color: Colors.black54),
//                       items: _statusTypes
//                           .map(
//                             (item) => DropdownMenuItem<String>(
//                               value: item,
//                               child: AutoSizeText(
//                                 item,
//                                 maxLines: 1,
//                                 style: GoogleFonts.poppins(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w400,
//                                     color: Colors.white),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                       onChanged: (item) => setState(() {
//                         widget.selectedStatusType = item;
//                         //addUserDetails();
//                       }),
//                     ),
//                   ),

//                   SizedBox(
//                     height: 30.h,
//                   ),

//                   //Name of status textfield
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       border: Border.all(color: Colors.white),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.only(left: 20.w),
//                       child: TextFormField(
//                         validator: (value) {
//                           if (value == '') {
//                             return 'Must have a name right';
//                           } else if (_isNumeric(value!)) {
//                             return 'Name got number meh';
//                           } else {
//                             return null;
//                           }
//                         },
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         controller: widget.statusName,
//                         decoration: InputDecoration(
//                           border: InputBorder.none,
//                           labelText: 'Enter Status Name:',
//                           labelStyle: GoogleFonts.poppins(
//                             color: Colors.white,
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 30.h,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       //Status start date picker
//                       Container(
//                         height: 55.h,
//                         width: 150.w,
//                         decoration: BoxDecoration(
//                           color: Colors.black54,
//                           border: Border.all(color: Colors.white),
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 15.w, vertical: 15.h),
//                           child: AutoSizeText(
//                             widget.startDate,
//                             //sDate,
//                             style: GoogleFonts.poppins(
//                                 color: Colors.white, fontSize: 16.sp),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(8.0.sp),
//                         child: InkWell(
//                           onTap: () {
//                             _showStartDatePicker();
//                           },
//                           child: const Icon(
//                             Icons.date_range_rounded,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),

//                       SizedBox(
//                         width: 10.w,
//                       ),

//                       //Status end date picker
//                       Container(
//                         width: 145.w,
//                         height: 55.h,
//                         decoration: BoxDecoration(
//                           color: Colors.black54,
//                           border: Border.all(color: Colors.white),
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 15.w, vertical: 15.h),
//                           child: AutoSizeText(
//                             widget.endDate,
//                             //eDate,
//                             style: GoogleFonts.poppins(
//                                 color: Colors.white, fontSize: 16.sp),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(8.0.sp),
//                         child: InkWell(
//                           onTap: () {
//                             _showEndDatePicker();
//                           },
//                           child: const Icon(
//                             Icons.date_range_rounded,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 40.h,
//                   ),

//                   GestureDetector(
//                     onTap: () {
//                       //print(widget.selectedItem);
//                       if (_formKey.currentState!.validate()) {
//                         IconSnackBar.show(
//                             duration: const Duration(seconds: 2),
//                             direction: DismissDirection.horizontal,
//                             context: context,
//                             snackBarType: SnackBarType.save,
//                             label: 'Status tile created',
//                             snackBarStyle: const SnackBarStyle() // this one
//                             );
//                         addUserStatus();
//                       } else {
//                         IconSnackBar.show(
//                             direction: DismissDirection.horizontal,
//                             context: context,
//                             snackBarType: SnackBarType.alert,
//                             label: 'Details missing',
//                             snackBarStyle: const SnackBarStyle() // this one
//                             );
//                       }
//                     }, //display, //
//                     child: Container(
//                       padding: EdgeInsets.all(10.sp),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.deepPurple.shade400,
//                             Colors.deepPurple.shade700,
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         //color: Colors.deepPurple,
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Center(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.add_to_photos_rounded,
//                               color: Colors.white,
//                               size: 30.sp,
//                             ),
//                             SizedBox(
//                               width: 20.w,
//                             ),
//                             AutoSizeText(
//                               'ADD STATUS',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 22.sp,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
