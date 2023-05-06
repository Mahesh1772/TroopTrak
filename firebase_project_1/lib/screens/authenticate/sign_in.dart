import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_project_1/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  //Placeholders for the email and password input by user
  final _emailId = TextEditingController();
  final _password = TextEditingController();

  Future isSignedIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailId.text.trim(), 
      password: _password.text.trim(),
      );
  }

  @override
  void dispose() {
     _emailId.dispose();
     _password.dispose();
     super.dispose();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 120,),
                const Icon(
                  Icons.military_tech_outlined,
                  size: 175,
                  color: Colors.deepPurpleAccent,
                ),
                const SizedBox(height: 80),
                //welcome text
                Text(
                  'Welcome to camp!',
                  style: GoogleFonts.kanit(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade300,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Time to get back!',
                  style: GoogleFonts.kanit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade400,
                  ),
                ),
                const SizedBox(height: 50),
                // email
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
                            border: InputBorder.none,
                            hintText: 'Email@example.com'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // password
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
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: 'Enter Password'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // sign in
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: isSignedIn,
                    child: Container(
                      padding: const EdgeInsets.all(25),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'No account?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Create one here!',
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}