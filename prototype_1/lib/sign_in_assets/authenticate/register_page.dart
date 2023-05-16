import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Placeholders for the email and password input by user
  final _emailId = TextEditingController();
  final _password = TextEditingController();
  final _confirmedpassword = TextEditingController();
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

  Future signUp() async {
    if (_confirmedpassword.text.trim() == _password.text.trim()) {
      //creating user
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailId.text.trim(),
        password: _password.text.trim(),
      );

      //Adding user details
      addUserDetails();
    }
  }

  Future addUserDetails() async {
    await FirebaseFirestore.instance.collection('Users').add({
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
    });
  }

  @override
  void dispose() {
    _emailId.dispose();
    _password.dispose();
    _confirmedpassword.dispose();
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
      //resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 45, 60, 68),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),

                //welcome text
                Text(
                  'Congrats on Graduation!',
                  style: GoogleFonts.kanit(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade300,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Make your life easier, Register',
                  style: GoogleFonts.kanit(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple.shade400,
                  ),
                ),
                const SizedBox(height: 30),

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

                // email
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
                        controller: _emailId,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Email@example.com'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // password
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
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Password'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // confirm password
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
                        controller: _confirmedpassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Confirm Your Password'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // sign in
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signUp,
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
                          'Sign Up',
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Alr have an account?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade300,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: const Text(
                        'Login here',
                        style: TextStyle(
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
