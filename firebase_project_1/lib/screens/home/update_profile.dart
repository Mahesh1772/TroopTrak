import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateProfile extends StatefulWidget {
  UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfile();
}

final _rank = TextEditingController();
final _name = TextEditingController();
final _appointment = TextEditingController();
final _rationType = TextEditingController();
final _status = TextEditingController();
final _mobileNumber = TextEditingController();
final _bloodgroup = TextEditingController();
final _dob = TextEditingController();
final _ord = TextEditingController();
final _attendence = TextEditingController();

class _UpdateProfile extends State<UpdateProfile> {
  var db = FirebaseFirestore.instance;

  Future adduser() async {
    //Adding user details
    addUserDetails();

    Navigator.pop(context);
  }

  Future addUserDetails() async {
    await db.collection('Users').doc(_name.text.trim()).set({
      //User map formatting
      'rank': _rank.text.trim(),
      //'name': _name.text.trim(),
      'appointment': _appointment.text.trim(),
      'rationType': _rationType.text.trim(),
      'status': _status.text.trim(),
      'mobileNumber': _mobileNumber.text.trim(),
      'bloodgroup': _bloodgroup.text.trim(),
      'dob': _dob.text.trim(),
      'ord': _ord.text.trim(),
      'attendence': _attendence.text.trim(),
    });
    /*await db.collection('Users').add({
      //User map formatting
      'rank': _rank.text.trim(),
      'name': _name.text.trim(),
      'appointment': _appointment.text.trim(),
      'rationType': _rationType.text.trim(),
      'status': _status.text.trim(),
      'mobileNumber': _mobileNumber.text.trim(),
      'bloodgroup': _bloodgroup.text.trim(),
      'dob': _dob.text.trim(),
      'ord': _ord.text.trim(),
      'attendence': _attendence.text.trim(),
    });*/
  }

  @override
  void dispose() {
    _rank.dispose();
    _name.dispose();
    _appointment.dispose();
    _rationType.dispose();
    _status.dispose();
    _mobileNumber.dispose();
    _bloodgroup.dispose();
    _dob.dispose();
    _ord.dispose();
    _attendence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_sharp,
                    color: Colors.black,
                  ),
                ),
              ),
              // rank
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _rank,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your Rank'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Name as in NRIC'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Appointment
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _appointment,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Your Appointment'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ration type
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _rationType,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Your Ration type'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _status,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Any statuses'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // mobile number
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _mobileNumber,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Your Mobile Number'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // blood type
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _bloodgroup,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Your blood group'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Date of Birth
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _dob,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Date of Birth'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ORD date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _ord,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Your favourite ORD date'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Attendence to create the percentage indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: _attendence,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Attendence: Inside or Out'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // sign in
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: adduser,
                  child: Container(
                    padding: const EdgeInsets.all(25),
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
                    child: const Center(
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
