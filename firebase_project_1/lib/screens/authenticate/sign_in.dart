import 'package:firebase_project_1/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  /*
  //Instance of AuthService class from auth.dart
  final AuthService _auth = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0.0,
        title: const Text('Sign in!'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 50,
        ),
        child: ElevatedButton(
          child: const Text('Sign in Anonymously'),
          onPressed: () async {
            //On button press, the signInAnon function is called,
            // and the code waits for a value to return. 
            // Which is then stored in result
            dynamic result = await _auth.signInAnon();
            if (result == null) {
              print('Error Signing in');
            }
            else {
              print('Sign in successful');
              print(result);
            }
          },
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.military_tech_outlined, size: 175,
              color: Colors.deepPurpleAccent,),
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
                style:  GoogleFonts.kanit(
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
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: TextField(
                      decoration: InputDecoration(
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
                  child: const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Enter Password'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // sign in
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
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
                  SizedBox(width: 10,),
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
    );
  }
}
