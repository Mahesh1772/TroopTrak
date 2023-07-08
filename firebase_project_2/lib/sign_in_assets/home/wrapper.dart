import 'package:firebase_project_2/sign_in_assets/services/auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //return Home if logged in, Else return authentication page
    return const AuthService();
  }
}
