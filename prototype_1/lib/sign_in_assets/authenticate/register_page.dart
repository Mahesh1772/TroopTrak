import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:recase/recase.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isProperPassword = false;

  bool _isNumeric(String str) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
    return numericRegex.hasMatch(str);
  }

  String? validateEmail(String val) {
    if (val.isEmpty) {
      return "Email can not be empty";
    } else if (!EmailValidator.validate(val, true)) {
      return "Invalid Email Address";
    }
    return '';
  }

  bool _isvalidaEmail(String val) {
    if (val.isEmpty) {
      return false;
    } else if (!EmailValidator.validate(val, true)) {
      return false;
    }
    return true;
  }

  String? validatePassword(String val) {
    if (val.isEmpty) {
      return "Password can not be empty";
    } else if (val.length < 8) {
      return "Password should be atleast 8 charecters long";
    }
    return '';
  }

  bool _isvalidPassword(String val) {
    if (val.isEmpty) {
      return false;
    } else if (val.length < 8) {
      return false;
    }
    return true;
  }

  //Placeholders for the email and password input by user
  final _name = TextEditingController();
  final _appointment = TextEditingController();
  final _emailId = TextEditingController();
  final _password = TextEditingController();
  final _confirmedpassword = TextEditingController();
  final _company = TextEditingController();
  final _platoon = TextEditingController();
  final _section = TextEditingController();
  final _rationTypes = [
    "Select ration type...",
    "NM",
    "M",
    "VI",
    "VC",
    "SD NM",
    "SD M",
    "SD VI",
    "SD VC"
  ];

  final _ranks = [
    "Select rank...",
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

  final _bloodTypes = [
    "Select blood type...",
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

  late String dob = DateFormat('d MMM yyyy').format(DateTime.now());
  late String ord = DateFormat('d MMM yyyy').format(DateTime.now());
  late String enlistment = DateFormat('d MMM yyyy').format(DateTime.now());
  late String? selectedItem = "Select ration type...";
  late String? selectedRank = "Select rank...";
  late String? selectedBloodType = "Select blood type...";

  Future signUp() async {
    try {
      if (_confirmedpassword.text.trim() == _password.text.trim() &&
          (_name.text.titleCase.trim() == '' ||
              _isNumeric(_name.text.titleCase.trim()) == false)) {
        //creating user
        UserCredential result =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailId.text.trim(),
          password: _password.text.trim(),
        );
        User user = result.user!;
        user.updateDisplayName(_name.text.trim());
        //Adding user details
        addUserDetails();
        addAttendanceDetails();
      }
      FirebaseAuth.instance.signOut();
    } catch (e) {
      IconSnackBar.show(
          context: context,
          snackBarType: SnackBarType.fail,
          label: 'This Email in use/ Enter Email and Password',
          snackBarStyle: const SnackBarStyle() // this one
          );
    }
  }

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
      });
    });
  }

  Future addUserDetails() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(_name.text.titleCase.trim())
        .set({
      //User map formatting
      'name': _name.text.titleCase.trim(),
      'rank': selectedRank,
      'company': _company.text.trim(),
      'platoon': _platoon.text.trim(),
      'section': _section.text.trim(),
      'appointment': _appointment.text.trim(),
      'rationType': selectedItem,
      'bloodgroup': selectedBloodType,
      'dob': dob,
      'ord': ord,
      'enlistment': enlistment,
      'points': 0,
    });
  }

  Future addAttendanceDetails() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(_name.text.titleCase.trim())
        .collection('Attendance')
        .doc(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()))
        .set({
      //User map formatting
      'isInsideCamp': true,
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(DateTime.now()),
    });
  }

  @override
  void dispose() {
    _emailId.dispose();
    _password.dispose();
    _confirmedpassword.dispose();
    _company.dispose();
    _platoon.dispose();
    _section.dispose();
    _name.dispose();
    _appointment.dispose();
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
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),

                    //welcome text
                    Text(
                      'Sign Up!',
                      style: GoogleFonts.poppins(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade300,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Make your life easier, Register',
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple.shade400,
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // name
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: TextFormField(
                          key: const Key("name"),
                          validator: (value) {
                            if (value == '') {
                              return 'You must have a name right';
                            } else if (_isNumeric(value!)) {
                              return 'Your name got number meh';
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          controller: _name,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Enter Name (as in NRIC):',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Appointment
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: TextFormField(
                          key: const Key("appointment"),
                          validator: (value) {
                            if (value == '') {
                              return 'Appointment Missing';
                            }
                            return null;
                          },
                          controller: _appointment,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Appointment (in unit):',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //Date of birth date picker
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 15.h),
                            child: Text(
                              dob,
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 16.sp),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.sp),
                          child: InkWell(
                            key: const Key("dob"),
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
                          padding: EdgeInsets.only(left: 10.0.w),
                          child: Container(
                            width: 230.w,
                            height: 55.h,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: DropdownButtonFormField<String>(
                              key: const Key("rationType"),
                              validator: (value) {
                                if (value == "Select your ration type...") {
                                  return 'Walao what food you eat?';
                                }
                                return null;
                              },
                              alignment: Alignment.center,
                              dropdownColor: Colors.black54,
                              value: selectedItem,
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
                                        style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (item) => setState(() {
                                selectedItem = item;
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    Row(
                      children: [
                        //Rank dropdown menu
                        Container(
                          width: 170.w,
                          height: 55.h,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: DropdownButtonFormField<String>(
                            key: const Key("rank"),
                            validator: (value) {
                              if (value == "Select your rank...") {
                                return 'Walao provide rank liao';
                              }
                              return null;
                            },
                            alignment: Alignment.center,
                            dropdownColor: Colors.black54,
                            value: selectedRank,
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
                                      style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? item) async => setState(() {
                              selectedRank = item;
                            }),
                          ),
                        ),

                        //Blood type dropdown menu
                        Padding(
                          padding: EdgeInsets.only(left: 20.0.w),
                          child: Container(
                            width: 200.w,
                            height: 55.h,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: DropdownButtonFormField<String>(
                              key: const Key("bloodType"),
                              validator: (value) {
                                if (value == "Select your blood type...") {
                                  return 'Why your blood field empty ah?';
                                }
                                return null;
                              },
                              dropdownColor: Colors.black54,
                              alignment: Alignment.center,
                              value: selectedBloodType,
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
                                        style: GoogleFonts.poppins(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (item) async => setState(() {
                                selectedBloodType = item;
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    //Company textfield
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: TextFormField(
                          key: const Key("company"),
                          validator: (value) {
                            if (value == '') {
                              return 'Company Name Missing';
                            }
                            return null;
                          },
                          controller: _company,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Company:',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    //Platoon textfield
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: TextFormField(
                          key: const Key("platoon"),
                          validator: (value) {
                            if (value == '') {
                              return 'Platoon Information Missing';
                            }
                            return null;
                          },
                          controller: _platoon,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Platoon:',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    //Section textfield
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: TextFormField(
                          key: const Key("section"),
                          validator: (value) {
                            if (value == '') {
                              return 'Section Information Missing';
                            }
                            return null;
                          },
                          controller: _section,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Section/Detail:',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    //Enlistment Date picker
                    Row(
                      children: [
                        SizedBox(
                          width: 150.w,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: Text(
                                enlistment,
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16.sp),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.sp),
                          child: InkWell(
                            key: const Key("enlistment"),
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
                          width: 130.w,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.w, vertical: 15.h),
                              child: Text(
                                ord,
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16.sp),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0.sp),
                          child: InkWell(
                            key: const Key("ord"),
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

                    SizedBox(height: 10.h),

                    // email
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: TextFormField(
                          key: const Key("email"),
                          validator: (value) {
                            if (_isvalidaEmail(value!) == false) {
                              return validateEmail(value);
                            } else {
                              return null;
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailId,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Email: (example - Email@example.com)',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    //Password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: TextFormField(
                          key: const Key("password"),
                          validator: (value) {
                            if (_isvalidPassword(value!) == false) {
                              return validatePassword(value);
                            } else if (isProperPassword == false) {
                              return 'Password needs to be stronger';
                            } else {
                              return null;
                            }
                          },
                          obscureText: true,
                          controller: _password,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Enter password:',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    FlutterPwValidator(
                        controller: _password,
                        minLength: 8,
                        uppercaseCharCount: 1,
                        lowercaseCharCount: 3,
                        numericCharCount: 1,
                        specialCharCount: 1,
                        width: 400.w,
                        height: 175.h,
                        onSuccess: () {
                          IconSnackBar.show(
                              direction: DismissDirection.horizontal,
                              context: context,
                              snackBarType: SnackBarType.save,
                              label: 'Password Approved',
                              snackBarStyle: const SnackBarStyle() // this one
                              );
                          setState(() {
                            isProperPassword = true;
                          });
                        },
                        onFail: () {
                          setState(() {
                            isProperPassword = false;
                          });
                        }),
                    SizedBox(height: 30.h),

                    // confirm password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: TextFormField(
                          key: const Key("confirmPassword"),
                          validator: (value) {
                            if (_isvalidPassword(value!) == false) {
                              return validatePassword(value);
                            } else if (_password.text.trim() ==
                                _confirmedpassword.text.trim()) {
                              return null;
                            } else {
                              return 'Make sure both Passwords match';
                            }
                          },
                          obscureText: true,
                          controller: _confirmedpassword,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Confirm password:',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // sign in
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                      child: GestureDetector(
                        key: const Key("signUpButton"),
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            IconSnackBar.show(
                                duration: const Duration(seconds: 4),
                                direction: DismissDirection.horizontal,
                                context: context,
                                snackBarType: SnackBarType.save,
                                label: 'User Profile created',
                                snackBarStyle: const SnackBarStyle() // this one
                                );
                            signUp();
                          } else {
                            IconSnackBar.show(
                                direction: DismissDirection.horizontal,
                                context: context,
                                snackBarType: SnackBarType.alert,
                                label: 'Details missing',
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
                              'Sign Up',
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
                    SizedBox(height: 15.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Alr have an account?',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade300,
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        GestureDetector(
                          onTap: widget.showLoginPage,
                          child: Text(
                            'Login here',
                            style: GoogleFonts.poppins(
                              color: Colors.tealAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
