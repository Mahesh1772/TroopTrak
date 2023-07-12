import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project_2/sign_in_assets/authenticate/authenticate.dart';
import 'package:firebase_project_2/util/new_navbar.dart';
import 'package:flutter/material.dart';

class AuthService extends StatelessWidget {
  const AuthService({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const GNavMainScreen();
          } else {
            return const Authenticate();
          }
        },
      ),
    );
  }
}