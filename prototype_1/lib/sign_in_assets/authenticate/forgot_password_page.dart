import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      ).then((value) => Navigator.pop(context));
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
            padding: EdgeInsets.symmetric(horizontal: 25.0.w),
            child: Text(
              'Enter in your Email, a reset link will be sent to it',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: Colors.tealAccent, fontSize: 20.sp),
            ),
          ),
          SizedBox(height: 20.h),

          //Textfield for email
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: TextField(
                  controller: _emailId,
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Email@example.com'),
                ),
              ),
            ),
          ),
          SizedBox(height: 15.h),

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
                style: GoogleFonts.poppins(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
