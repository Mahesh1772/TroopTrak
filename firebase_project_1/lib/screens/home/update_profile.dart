import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfile();
}

var _rank = TextEditingController();
var _name = TextEditingController();
var _appointment = TextEditingController();
var _rationType = TextEditingController();
var _status = TextEditingController();
var _mobileNumber = TextEditingController();
var _bloodgroup = TextEditingController();
var _dob = TextEditingController();
var _ord = TextEditingController();
var _attendence = TextEditingController();

class _UpdateProfile extends State<UpdateProfile> {
  var db = FirebaseFirestore.instance;

  Future adduser() async {
    //Adding user details
    addUserDetails();
    resetControllers();
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
  }

  void resetControllers() {
    _rank.clear();
    _name.clear();
    _appointment.clear();
    _rationType.clear();
    _status.clear();
    _mobileNumber.clear();
    _bloodgroup.clear();
    _dob.clear();
    _ord.clear();
    _attendence.clear();
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
                        border: OutlineInputBorder(),
                        labelText: 'Rank',
                        hintText: 'Enter your Rank',
                        suffixIcon: Icon(Icons.leaderboard_outlined),
                      ),
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
                        border: OutlineInputBorder(),
                        labelText: 'Full Name',
                        hintText: 'Enter Name as in NRIC',
                        suffixIcon: Icon(Icons.nature_people_outlined),
                      ),
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
                        border: OutlineInputBorder(),
                        labelText: 'Appointment',
                        hintText: 'Your Appointment',
                      ),
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
                          border: OutlineInputBorder(),
                          labelText: 'Ration Type',
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
                          border: OutlineInputBorder(),
                          labelText: 'Status',
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
                          border: OutlineInputBorder(),
                          labelText: 'Mobile Number',
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
                          border: OutlineInputBorder(),
                          labelText: 'Blood group',
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
                          border: OutlineInputBorder(),
                          labelText: 'DOB',
                          hintText: 'Date of Birth'),
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
                          border: OutlineInputBorder(),
                          labelText: 'ORD',
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
                          border: OutlineInputBorder(),
                          labelText: 'Attendence',
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
