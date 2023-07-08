// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_project_2/sign_in_assets/authenticate/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';

@visibleForTesting
String? validateEmail(String val) {
  if (val.isEmpty) {
    return "Email can not be empty";
  } else if (!EmailValidator.validate(val, true)) {
    return "Invalid Email Address";
  }
  return '';
}

@visibleForTesting
String? validatePassword(String val) {
  if (val.isEmpty) {
    return "Password can not be empty";
  } else if (val.length < 8) {
    return "Password should be at least 8 characters long";
  }
  return '';
}

class SignIn extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const SignIn({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late var width = MediaQuery.of(context).size.width;
  late var height = MediaQuery.of(context).size.height;

  //Placeholders for the email and password input by user
  final _emailId = TextEditingController();
  final _password = TextEditingController();
  String errorName = '';

  Future isSignedIn() async {
    //print('tap detected');
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailId.text.trim(),
        password: _password.text.trim(),
      );
      IconSnackBar.show(
          duration: const Duration(seconds: 4),
          direction: DismissDirection.horizontal,
          context: context,
          snackBarType: SnackBarType.save,
          label: 'Login Successful',
          snackBarStyle: const SnackBarStyle() // this one
          );
    } on FirebaseAuthException catch (e) {
      errorName = e.message!;
      print(errorName);
      IconSnackBar.show(
          context: context,
          snackBarType: SnackBarType.fail,
          label: 'Wrong Email/Password or Both',
          snackBarStyle: const SnackBarStyle() // this one
          );
    }
  }

  @override
  void dispose() {
    _emailId.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    bool _isvalidaEmail(String val) {
      if (val.isEmpty) {
        return false;
      } else if (!EmailValidator.validate(val, true)) {
        return false;
      }
      return true;
    }

    bool _isvalidPassword(String val) {
      if (val.isEmpty) {
        return false;
      } else if (val.length < 8) {
        return false;
      }
      return true;
    }

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 45, 60, 68),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 80.h,
                  ),
                  Icon(
                    Icons.military_tech_outlined,
                    size: 150.sp,
                    color: Colors.deepPurpleAccent,
                  ),
                  SizedBox(height: 80.h),
                  //welcome text
                  Text(
                    'Welcome to camp!',
                    style: GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade300,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Time to get back!',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade400,
                    ),
                  ),
                  SizedBox(height: 50.h),

                  // email
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
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailId,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            border: InputBorder.none,
                            hintText: 'Email@example.com',
                            labelText: 'Email ID',
                          ),
                          validator: (value) {
                            if (_isvalidaEmail(value!) == false) {
                              return validateEmail(value);
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // password
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
                        child: TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.lock_open),
                              hintText: 'Enter Password',
                              labelText: 'Password'),
                          validator: (value) {
                            if (_isvalidPassword(value!) == false) {
                              return validatePassword(value);
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  //Forgot Password button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const ForgotPassword();
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password? Aiyahhh',
                            style: GoogleFonts.poppins(
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // sign in
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                    child: GestureDetector(
                      onTap: () {
                        if (formKey.currentState!.validate()) {
                          isSignedIn();
                        } else {
                          IconSnackBar.show(
                              direction: DismissDirection.horizontal,
                              context: context,
                              snackBarType: SnackBarType.alert,
                              label: 'Fill in all the fields',
                              snackBarStyle: const SnackBarStyle() // this one
                              );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(25.sp),
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
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 35.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No account?',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade300,
                        ),
                      ),
                      SizedBox(
                        width: 10.h,
                      ),
                      GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: Text(
                          'Create one here!',
                          style: GoogleFonts.poppins(
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
      ),
    );
  }
}
