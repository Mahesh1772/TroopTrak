// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';

class AddNewStatusScreen extends StatefulWidget {
  AddNewStatusScreen(
      {super.key,
      required this.selectedStatusType,
      required this.statusName,
      required this.startDate,
      required this.endDate});

  late TextEditingController statusName;
  late String? selectedStatusType;
  late String startDate;
  late String endDate;

  @override
  State<AddNewStatusScreen> createState() => _AddNewStatusScreenState();
}

class _AddNewStatusScreenState extends State<AddNewStatusScreen> {
  final _statusTypes = [
    "Select status type...",
    "Excuse",
    "Leave",
    "Medical Appointment",
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
        .doc(widget.statusName.text)
        .update({
      //User map formatting
      'statusName': widget.statusName.text.trim(),
      'statusType': widget.selectedStatusType,
      'startDate': widget.startDate,
      'endDate': widget.endDate,
    });
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  "Let's add a new status for this soldier ✍️",
                  30,
                  fontWeight: FontWeight.bold,
                ),
                const StyledText(
                  "Fill in the details of the status",
                  14,
                  fontWeight: FontWeight.w300,
                ),
                const SizedBox(
                  height: 40,
                ),
                //Status type drop down menu
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    alignment: Alignment.center,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? item) async => setState(() {
                      widget.selectedStatusType = item;
                      addUserDetails();
                    }),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                //Name of status textfield
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      controller: widget.statusName,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Enter Status Name:',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Status start date picker
                    Container(
                      height: 55,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: AutoSizeText(
                          widget.startDate,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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

                    const SizedBox(
                      width: 10,
                    ),

                    //Status end date picker
                    Container(
                      width: 145,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: AutoSizeText(
                          widget.endDate,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                const SizedBox(
                  height: 40,
                ),

                GestureDetector(
                  onTap: addUserDetails,
                  child: Container(
                    padding: const EdgeInsets.all(10),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_to_photos_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          AutoSizeText(
                            'ADD STATUS',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
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
