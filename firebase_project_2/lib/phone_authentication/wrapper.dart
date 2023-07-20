import 'package:firebase_project_2/phone_authentication/commander_or_man_choice_screen.dart';
import 'package:firebase_project_2/phone_authentication/widgets/button_wrapper.dart';
import 'package:firebase_project_2/util/text_styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //return Home if logged in, Else return authentication page
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 25, 34),
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/phone_auth/troopTrak_mascot.png',
                height: 300.sp,
                color: Colors.deepPurpleAccent,
              ),
              StyledText("TroopTrak", 46.sp, fontWeight: FontWeight.bold),
              SizedBox(height: 70.h),
              //welcome text
              Text(
                'Welcome!',
                style: GoogleFonts.poppins(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade300,
                ),
              ),
              const SizedBox(height: 40),
              //welcome text
              Text(
                'Time to book in 😄',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.purple.shade100,
                ),
              ),
              const SizedBox(height: 50),
              WrapperButton(
                label: 'GET STARTED',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommanderOrManSelectScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      )),
    );
    //return const AuthService();
  }
}
