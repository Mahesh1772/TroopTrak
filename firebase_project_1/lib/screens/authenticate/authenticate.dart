import 'package:firebase_project_1/screens/authenticate/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_project_1/screens/authenticate/register_page.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  //initially show sign in page
  bool onSignInPage = true;

  void toggleBetweenScreens() {
    setState(() {
      onSignInPage = !onSignInPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (onSignInPage) {
      return SignIn(showRegisterPage: toggleBetweenScreens);
    } else {
      return RegisterPage(showLoginPage: toggleBetweenScreens);
    }
  }
}
