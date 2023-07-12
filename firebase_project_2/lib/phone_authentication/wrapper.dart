import 'package:firebase_project_2/phone_authentication/register_page.dart';
import 'package:firebase_project_2/widgets/button_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //return Home if logged in, Else return authentication page
    return Scaffold(
      backgroundColor: Colors.black12,
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
                height: 300,
                color: Colors.deepPurpleAccent,
              ),
              const SizedBox(height: 50),
              //welcome text
              Text(
                'Welcome Back Comrade🫡!',
                style: GoogleFonts.kanit(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade300,
                ),
              ),
              const SizedBox(height: 40),
              //welcome text
              Text(
                'Book in time😄!',
                style: GoogleFonts.kanit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.purple.shade100,
                ),
              ),
              const SizedBox(height: 50),
              WrapperButton(
                label: 'Get started',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    )),
              )
            ],
          ),
        ),
      )),
    );
    //return const AuthService();
  }
}
