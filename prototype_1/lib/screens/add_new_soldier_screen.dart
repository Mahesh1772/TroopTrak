import 'package:flutter/material.dart';
import 'package:prototype_1/util/text_style.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNewSoldierPage extends StatefulWidget {
  const AddNewSoldierPage({super.key});

  @override
  State<AddNewSoldierPage> createState() => _AddNewSoldierPageState();
}

class _AddNewSoldierPageState extends State<AddNewSoldierPage> {
  var db = FirebaseFirestore.instance;

  final _name = TextEditingController();
  final _company = TextEditingController();
  final _platoon = TextEditingController();
  final _section = TextEditingController();
  final _appointment = TextEditingController();
  final _mobilenumber = TextEditingController();
  String dob = 'Date of birth:';
  String ord = "ORD:";
  String enlistment = "Enlistment Date:";

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
  String? _selectedItem = "Select your ration type...";
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
  String? _selectedRank = "Select your rank...";

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
  String? _selectedBloodType = "Select your blood type...";

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        if (value != null) {
          dob = DateFormat.yMMMd().format(value).toString();
        }
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
          ord = DateFormat.yMMMd().format(value).toString();
        }
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
          enlistment = DateFormat.yMMMd().format(value).toString();
        }
      });
    });
  }

  Future addUserDetails() async {
    await db.collection('Users').doc(_name.text.trim()).set({
      //User map formatting
      'rank': _selectedRank,
      //'name': _name.text.trim(),
      'company': _company.text.trim(),
      'platoon': _platoon.text.trim(),
      'section': _section.text.trim(),
      'appointment': _appointment.text.trim(),
      'rationType': _selectedItem,
      'mobileNumber': _mobilenumber.text.trim(),
      'bloodgroup': _selectedBloodType,
      'dob': dob..trim(),
      'enlistment': enlistment.trim(),
      'ord': ord.trim(),
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _company.dispose();
    _platoon.dispose();
    _section.dispose();
    _mobilenumber.dispose();
    _appointment.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: keyboardIsOpened
          ? null
          : FloatingActionButton.extended(
              label: const Center(
                child: StyledText("ADD NEW SOLDIER", 24,
                    fontWeight: FontWeight.bold),
              ),
              icon: const Icon(
                Icons.group_add_rounded,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                addUserDetails();
                Navigator.pop(context);
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              backgroundColor: Colors.deepPurple,
            ),
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
                      style: TextStyle(color: Colors.pink.shade200),
                      controller: _name,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          hintText: 'Name (as per NRIC):'),
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
                          dob,
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
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          dropdownColor: Colors.black54,
                          value: _selectedItem,
                          icon: const Icon(
                            Icons.arrow_downward_sharp,
                            color: Colors.white,
                          ),
                          style: const TextStyle(color: Colors.black54),
                          items: _rationTypes
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (item) =>
                              setState(() => _selectedItem = item),
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
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: DropdownButton<String>(
                          dropdownColor: Colors.black54,
                          value: _selectedRank,
                          icon: Image.asset(
                            "lib/assets/army-ranks/3sg.png",
                            width: 20,
                            color: Colors.white,
                          ),
                          style: const TextStyle(color: Colors.black54),
                          items: _ranks
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (item) =>
                              setState(() => _selectedRank = item),
                        ),
                      ),
                    ),
                    //Blood type dropdown menu
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          dropdownColor: Colors.black54,
                          value: _selectedBloodType,
                          icon: const Icon(
                            Icons.water_drop_sharp,
                            color: Colors.red,
                          ),
                          style: const TextStyle(color: Colors.black54),
                          items: _bloodTypes
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (item) =>
                              setState(() => _selectedBloodType = item),
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
                      style: TextStyle(color: Colors.pink.shade200),
                      controller: _company,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          hintText: 'Company:'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

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
                      style: TextStyle(color: Colors.pink.shade200),
                      controller: _platoon,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          hintText: 'Platoon:'),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

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
                      style: TextStyle(color: Colors.pink.shade200),
                      controller: _section,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          hintText: 'Section / Det:'),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

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
                      controller: _appointment,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.white),
                          hintText: 'Appointment in unit:'),
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
                            enlistment,
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
                            ord,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: SizedBox(
                            width: 175.0,
                            child: TextField(
                              style: TextStyle(color: Colors.pink.shade200),
                              controller: _mobilenumber,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.white),
                                hintText: 'Mobile Number',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
