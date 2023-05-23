import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateUser extends StatefulWidget {
  const UpdateUser({super.key});

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

var fname = FirebaseAuth.instance.currentUser!.displayName.toString();
var id = FirebaseAuth.instance.currentUser!;
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

class _UpdateUserState extends State<UpdateUser> {
  var db = FirebaseFirestore.instance;

  Future updateuser() async {
    //Adding user details
    updateUserDetails();
    //resetControllers();
    Navigator.pop(context);
  }

  Future updateUserDetails() async {
    await db.collection('Users').doc(_name.text.trim()).set({
      //User map formatting
      'rank': _rank.text.trim(),
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

  Future deleteUserAccount() async{
    deleteCurrentUser();
    id.delete();
    Navigator.pop(context);
  }

  Future deleteCurrentUser() async {
    db.collection("Users").doc(_name.text.trim()).delete();
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
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(fname)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  //We are trying to map the key and values pairs
                  //to a variable called "data" of Type Map
                  Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
    
                  // Populating the controllers with pre-existing value
                   _name = TextEditingController(text: fname);
                   _rank = TextEditingController(text: data['rank']);
                   _appointment = TextEditingController(text: data['appointment']);
                   _rationType = TextEditingController(text: data['rationType']);
                   _status = TextEditingController(text: data['status']);
                   _mobileNumber = TextEditingController(text: data['mobileNumber']);
                   _bloodgroup = TextEditingController(text: data['bloodgroup']);
                   _dob = TextEditingController(text: data['dob']);
                   _ord = TextEditingController(text: data['ord']);
                   _attendence = TextEditingController(text:data['attendence'] );
    
                  return Column(
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
                            child: TextFormField(
                              autofocus: false,
                              controller: _rank,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter your Rank',
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
                              controller: _name,//TextEditingController(text: fname),
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
                              controller:
                                  _rationType,
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
                              controller:
                                  _status,
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
                              controller:
                                  _bloodgroup,
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
                              controller:
                                  _dob,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
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
                              controller:
                                  _ord,
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
                              controller:
                                  _attendence,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Attendence: Inside or Out'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
    
                      // Update User
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: updateuser,
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
                                'Update Profile',
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

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: deleteUserAccount,
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 228, 113, 113),
                                  Color.fromARGB(255, 157, 4, 4),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              //color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Delete User',
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
                  );
                }
                return const Text('Loading......');
              },
            ),
          ),
        ),
      ),
    );
  }
}