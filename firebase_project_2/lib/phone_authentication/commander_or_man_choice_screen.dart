// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_project_2/phone_authentication/provider/auth_provider.dart';
import 'package:firebase_project_2/phone_authentication/register_page.dart';
import 'package:firebase_project_2/prototype_1_lib/lib/main.dart';
import 'package:firebase_project_2/util/new_navbar.dart';
import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CommanderOrManSelectScreen extends StatefulWidget {
  const CommanderOrManSelectScreen({super.key});

  @override
  State<CommanderOrManSelectScreen> createState() =>
      _CommanderOrManSelectScreenState();
}

class _CommanderOrManSelectScreenState
    extends State<CommanderOrManSelectScreen> {
  bool isPressed1 = false;
  bool isPressed2 = false;

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.checkSignIn();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0.sp),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isPressed2) {
                                isPressed2 = !isPressed2;
                              }
                              isPressed1 = !isPressed1;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            color: const Color.fromARGB(255, 21, 25, 34),
                            child: Container(
                              width: 170.w,
                              height: 280.h,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 33, 40, 54),
                                borderRadius: BorderRadius.circular(30.r),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0xff474b50),
                                      offset: isPressed1
                                          ? Offset(-5.w, -5.h)
                                          : Offset(-10.w, -10.h),
                                      blurRadius: isPressed1 ? 5.0.r : 20.0.r,
                                      spreadRadius: 0.0.r,
                                      inset: isPressed1),
                                  BoxShadow(
                                      color: const Color(0xff0b0f14),
                                      offset: isPressed1
                                          ? Offset(5.w, 5.h)
                                          : Offset(10.w, 10.h),
                                      blurRadius: isPressed1 ? 5.0.r : 20.0.r,
                                      spreadRadius: 0.0.r,
                                      inset: isPressed1),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "lib/assets/icons8-soldiers-64.png",
                                    width: 50.w,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  StyledText("Men", 18.sp,
                                      fontWeight: FontWeight.w500),
                                  AutoSizeText(
                                    "CFC and below",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isPressed1) {
                                isPressed1 = !isPressed1;
                              }

                              isPressed2 = !isPressed2;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            color: const Color.fromARGB(255, 21, 25, 34),
                            child: Container(
                              width: 170.w,
                              height: 280.h,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 33, 40, 54),
                                borderRadius: BorderRadius.circular(30.r),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0xff474b50),
                                      offset: isPressed2
                                          ? Offset(-5.w, -5.h)
                                          : Offset(-10.w, -10.h),
                                      blurRadius: isPressed2 ? 5.0.r : 20.0.r,
                                      spreadRadius: 0.0.r,
                                      inset: isPressed2),
                                  BoxShadow(
                                      color: const Color(0xff0b0f14),
                                      offset: isPressed2
                                          ? Offset(5.w, 5.h)
                                          : Offset(10.w, 10.h),
                                      blurRadius: isPressed2 ? 5.0.r : 20.0.r,
                                      spreadRadius: 0.0.r,
                                      inset: isPressed2),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "lib/assets/icons8-soldier-man-64.png",
                                    width: 50.w,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  StyledText("Commanders", 18.sp,
                                      fontWeight: FontWeight.w500),
                                  AutoSizeText(
                                    "3SG or higher",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const Spacer(),
                    StyledText(
                      "Please pick your role.",
                      36.sp,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    StyledText(
                      "If you are rank 3SG or higher, select commanders.",
                      16.sp,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                    ),
                    StyledText(
                      "If your rank is CFC or lower, select men.",
                      16.sp,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 60.h,
                    width: 60.w,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isPressed1) {
                          print(ap.isSignedIn);
                          ap.isSignedIn
                          //ap.userid != null
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GNavMainScreen(),
                                  ),
                                )
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                        } else if (isPressed2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyApp(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
