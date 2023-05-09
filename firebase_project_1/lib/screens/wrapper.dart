import 'package:firebase_project_1/services/auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //return Home is logged in, Else return authentication page
    return const AuthService();
  }
}
