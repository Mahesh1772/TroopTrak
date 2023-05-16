import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {
  final _emailId = TextEditingController();

  @override
  void dispose() {
    _emailId.dispose();
    super.dispose();
  }

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailId.text.trim(),
      );
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text(
              'Reset link has been sent to your Email account!',
            ),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      //print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(
              e.message.toString(),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade600,
        elevation: 10,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Enter in your Email, a reset link will be sent to it',
              textAlign: TextAlign.center,
              style: GoogleFonts.kanit(color: Colors.tealAccent, fontSize: 20),
            ),
          ),
          const SizedBox(height: 20),

          //Textfield for email
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
                      border: InputBorder.none, hintText: 'Email@example.com'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          //Button to send email
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurpleAccent.shade400,
                  Colors.deepPurpleAccent.shade200
                ],
              ),
            ),
            child: MaterialButton(
              onPressed: resetPassword,
              child: Text(
                'Reset Password',
                style: GoogleFonts.kanit(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
