// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewSoldierPage extends StatefulWidget {
  AddNewSoldierPage(
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
  State<AddNewSoldierPage> createState() => _AddNewSoldierPageState();
}

class _AddNewSoldierPageState extends State<AddNewSoldierPage> {
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
        //addUserDetails();
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
        //addUserDetails();
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
        //addUserDetails();
      });
    });
  }

  Future addUserDetails() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.name.text.trim())
        .set({
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
    Navigator.pop(context);
  }

  @override
  void dispose() {
    widget.name.dispose();
    widget.company.dispose();
    widget.platoon.dispose();
    widget.section.dispose();
    widget.appointment.dispose();
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
                      controller: widget.name,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Enter Name (as in NRIC):',
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
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //Date of birth date picker
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: Text(
                          widget.dob,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Container(
                        width: 205,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
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
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (item) => setState(() {
                            widget.selectedItem = item;
                            //addUserDetails();
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    //Rank dropdown menu
                    Container(
                      width: 160,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        alignment: Alignment.center,
                        dropdownColor: Colors.black54,
                        value: widget.selectedRank,
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
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (String? item) async => setState(() {
                          widget.selectedRank = item;
                          //addUserDetails();
                        }),
                      ),
                    ),

                    //Blood type dropdown menu
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Container(
                        width: 205,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          dropdownColor: Colors.black54,
                          alignment: Alignment.center,
                          value: widget.selectedBloodType,
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
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (item) async => setState(() {
                            widget.selectedBloodType = item;
                            //addUserDetails();
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                //Company textfield
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: widget.company,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Company:',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                //Platoon textfield
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: widget.platoon,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Platoon:',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                //Section textfield
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: widget.section,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Section:',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                //Soldier Appointment text field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: widget.appointment,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Appointment (in unit):',
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
                  height: 20,
                ),

                //Enlistment Date picker
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: Text(
                            widget.enlistment,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                    //ORD picker
                    SizedBox(
                      width: 150,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: Text(
                            widget.ord,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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

                const SizedBox(
                  height: 30,
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
                            Icons.group_add_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          AutoSizeText(
                            'ADD NEW SOLDIER',
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
