import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phone = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 35,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 350,
                    height: 350,
                    padding: const EdgeInsets.all(10),
                    transformAlignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      //color: Colors.blueGrey.shade800,
                    ),
                    child: Image.asset(
                      'lib/assets/phone_auth/troopTrak_logo.png',
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Enter Phone Number',
                    style: GoogleFonts.kanit(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade300,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'For Registration and login',
                    style: GoogleFonts.kanit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    cursorColor: Colors.deepPurple,
                    controller: _phone,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: GoogleFonts.kanit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.deepPurple,
                      ),
                      hintText: '9865 3214',
                      hintStyle: GoogleFonts.kanit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.deepPurple,
                      ),
                      fillColor: Colors.purple.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 3,
                          color: Colors.deepPurple.shade900,
                        ), //<-- SEE HERE

                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 3,
                          color: Colors.deepPurple.shade900,
                        ), //<-- SEE HERE

                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      //prefixIcon: Container(padding: EdgeInsets.all(8),)
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
