import 'package:firebase_project_2/phone_authentication/get_user_info.dart';
import 'package:firebase_project_2/phone_authentication/provider/auth_provider.dart';
import 'package:firebase_project_2/phone_authentication/widgets/button_wrapper.dart';
import 'package:firebase_project_2/util/new_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

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
    final isLoading =
        Provider.of<AuthProvider>(context, listen: true).isLoading;
    Vid = widget.verificationId;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SafeArea(
        child: SingleChildScrollView(
          child: isLoading
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.sp),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.arrow_back_sharp,
                                color: Colors.white,
                                size: 25.sp,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 50.h,
                          ),

                          Icon(
                            Icons.military_tech_outlined,
                            size: 180.sp,
                            color: Colors.deepPurpleAccent,
                          ),

                          SizedBox(
                            height: 20.h,
                          ),

                          //welcome text
                          Text(
                            'User Verification',
                            style: GoogleFonts.poppins(
                              fontSize: 35.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade300,
                            ),
                          ),

                          SizedBox(
                            height: 10.h,
                          ),

                          Text(
                            'Enter OTP Recieved',
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade400,
                            ),
                          ),

                          SizedBox(height: 30.h),

                          Pinput(
                            length: 6,
                            showCursor: true,
                            defaultPinTheme: PinTheme(
                              width: 46.w,
                              height: 66.h,
                              textStyle: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w800),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.purpleAccent,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onCompleted: (value) {
                              setState(() {
                                otp = value;
                                print(otp);
                              });
                            },
                          ),

                          SizedBox(height: 30.h),

                          WrapperButton(
                            label: 'Verify',
                            onPressed: () {
                              if (otp != null) {
                                verifyOTP(context, otp!);
                              } else {
                                IconSnackBar.show(
                                    direction: DismissDirection.horizontal,
                                    context: context,
                                    snackBarType: SnackBarType.alert,
                                    label: 'Enter 6 digit code',
                                    snackBarStyle:
                                        const SnackBarStyle() // this one
                                    );
                              }
                            },
                          ),

                          SizedBox(
                            height: 20.h,
                          ),
                          //welcome text
                          Text(
                            "Did not recieve OTP?",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade300,
                            ),
                          ),

                          SizedBox(
                            height: 20.h,
                          ),
                          //welcome text
                          Text(
                            'Resend New OTP',
                            style: GoogleFonts.poppins(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 187, 231, 74),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void verifyOTP(BuildContext context, String otp) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOTP(
        context: context,
        verificationId: widget.verificationId,
        otp: otp,
        onsuccess: () {
          //check whether user existsin the Database
          ap.checkExistingUser().then((value) async {
            if (value) {
              //User alr exists
              ap.getUserData().then((value) {
                ap.setSignIn();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GNavMainScreen(),
                  ),
                  (route) => false,
                );
              });
            } else {
              //Need to get all the information
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNewMen(),
                ),
              );
            }
          });
        });
  }
}
