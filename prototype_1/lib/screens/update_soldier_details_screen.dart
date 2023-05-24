import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateSoldierDetailsPage extends StatefulWidget {
  const UpdateSoldierDetailsPage({super.key});

  @override
  State<UpdateSoldierDetailsPage> createState() =>
      _UpdateSoldierDetailsPageState();
}

class _UpdateSoldierDetailsPageState extends State<UpdateSoldierDetailsPage> {
  Future deleteCurrentUser() async {
    FirebaseFirestore.instance.collection("Users").doc(docIDs).delete();
    Navigator.pop(context);
  }

  final docIDs = 'Lee Kuan Yew';
  var _name = TextEditingController();
  var _company = TextEditingController();
  var _platoon = TextEditingController();
  var _section = TextEditingController();
  var _appointment = TextEditingController();
  var _mobilenumber = TextEditingController();
  String dob = 'Date of birth:';
  String ord = "ORD:";
  String enlistment = 'Enlistment';

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
  String? _selectedItem = 'dddd';

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
  String? _selectedRank = 'dddd';

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
  String? _selectedBloodType = 'dddd';

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(dob),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        if (value != null) {
          dob = DateFormat('d MMM yyyy').format(value);
        }
        addUserDetails();
      });
    });
  }

  void _ordDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(ord),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          ord = DateFormat('d MMM yyyy').format(value);
        }
        addUserDetails();
      });
    });
  }

  void _enlistmentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateFormat("d MMM yyyy").parse(enlistment),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        if (value != null) {
          enlistment = DateFormat('d MMM yyyy').format(value);
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
        .doc(_name.text.trim())
        .update({
      //User map formatting
      'rank': _selectedRank,
      'name': _name.text.trim(),
      'company': _company.text.trim(),
      'platoon': _platoon.text.trim(),
      'section': _section.text.trim(),
      'appointment': _appointment.text.trim(),
      'rationType': _selectedItem,
      'bloodgroup': _selectedBloodType,
      'dob': dob,
      'ord': ord,
      'enlistment': enlistment,
    });
  }

  void resetControllers() {
    _name.clear();
    _company.clear();
    _platoon.clear();
    _section.clear();
    _appointment.clear();
    _mobilenumber.clear();
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
                .doc(docIDs)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //We are trying to map the key and values pairs
                //to a variable called "data" of Type Map
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;

                // Populating the controllers with pre-existing value
                _name = TextEditingController(text: docIDs);
                dob = data['dob'];
                _selectedRank = data['rank'];
                _appointment = TextEditingController(text: data['appointment']);
                _selectedItem = data['rationType'];
                _section = TextEditingController(text: data['section']);
                _platoon = TextEditingController(text: data['platoon']);
                _company = TextEditingController(text: data['company']);
                _mobilenumber =
                    TextEditingController(text: data['mobileNumber']);
                _selectedBloodType = data['bloodgroup'];
                ord = data['ord'];
                enlistment = data['enlistment'];

                return Padding(
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
                        "Change details  ✍️",
                        30,
                        fontWeight: FontWeight.bold,
                      ),
                      const StyledText(
                        "Update the details of an existing soldier.",
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
                            controller: _name,
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
                      const SizedBox(height: 10),
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
                                  _selectedItem = item;
                                  addUserDetails();
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
                              value: _selectedRank ?? data['rank']!,
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
                                _selectedRank = item;
                                addUserDetails();
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
                                value:
                                    _selectedBloodType ?? data['bloodgroup']!,
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
                                  _selectedBloodType = item;
                                  addUserDetails();
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
                            controller: _company,
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
                            controller: _platoon,
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
                            controller: _section,
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
                            controller: _appointment,
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
                      const SizedBox(height: 20),

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
                        ],
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: GestureDetector(
                              onTap: updateUserDetails,
                              child: Container(
                                padding: const EdgeInsets.all(16),
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
                                    children: [
                                      const Icon(
                                        Icons.edit_note_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      AutoSizeText(
                                        'UPDATE DETAILS',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: GestureDetector(
                              onTap: deleteCurrentUser,
                              child: Container(
                                padding: const EdgeInsets.all(16),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete_forever_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      AutoSizeText(
                                        'DELETE DETAILS',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
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
