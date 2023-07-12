import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/phone_authentication/register_page.dart';
import 'package:firebase_project_2/util/new_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.verificationId,
  });

  final String verificationId;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

String Vid = '';
String Uid = '';

class _OtpScreenState extends State<OtpScreen> {
  String? otp;
  @override
  Widget build(BuildContext context) {
    Vid = widget.verificationId;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 45, 60, 68),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_sharp,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  const Icon(
                    Icons.military_tech_outlined,
                    size: 180,
                    color: Colors.deepPurpleAccent,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  //welcome text
                  Text(
                    'User verification',
                    style: GoogleFonts.kanit(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade300,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    'Enter OTP recieved',
                    style: GoogleFonts.kanit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade400,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Pinput(
                    length: 6,
                    showCursor: true,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: GoogleFonts.kanit(
                          fontSize: 20,
                          color: Colors.amber,
                          fontWeight: FontWeight.w800),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purpleAccent,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onCompleted: (value) {
                      setState(() {
                        otp = value;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        if (otp!.isEmpty) {
                          IconSnackBar.show(
                              duration: const Duration(seconds: 2),
                              direction: DismissDirection.horizontal,
                              context: context,
                              snackBarType: SnackBarType.save,
                              label: 'Enter OTP fully ah',
                              snackBarStyle: const SnackBarStyle() // this one
                              );
                        } else {
                          verifyOTP(context, otp!);
                        }
                      },
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Get verification',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  //welcome text
                  Text(
                    "Did not recieve OTP?",
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade300,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  //welcome text
                  Text(
                    'Resed New OTP',
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 187, 231, 74),
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

void verifyOTP(BuildContext context, String otp) async {
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: Vid,
      smsCode: otp,
    );
    User? user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    if (user != null) {
      Uid = user.uid;
      checkExistingUser().then((value) async {
        if (value) {
          // Old user
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const GNavMainScreen(),
              ),
              (route) => false);
        } else {
          // New user
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RegisterPage(showLoginPage: toggleBetweenScreens),
              ),
              (route) => false);
        }
      });
    }
  } catch (e) {
    IconSnackBar.show(
        duration: const Duration(seconds: 2),
        direction: DismissDirection.horizontal,
        context: context,
        snackBarType: SnackBarType.save,
        label: e.toString(),
        snackBarStyle: const SnackBarStyle() // this one
        );
  }
}

void toggleBetweenScreens() {}

Future<bool> checkExistingUser() async {
  DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('Men').doc(Uid).get();
  if (snapshot.exists) {
    print('User Exists');
    return true;
  } else {
    print('User does not Exist');
    return false;
  }
}
