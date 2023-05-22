import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_project_1/screens/authenticate/sign_in.dart';

class UpdateUser extends StatefulWidget {
  const UpdateUser({super.key});

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  var auth = FirebaseAuth.instance.currentUser!;
  var fname = FirebaseAuth.instance.currentUser!.displayName.toString();

  // here you write the codes to input the data into firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(
          child: Text(
            textAlign: TextAlign.center,
            'User Profile',
            style: TextStyle(
              fontSize: 30,
              color: Colors.tealAccent.shade400,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(
                Icons.exit_to_app_sharp,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(fname),
          ],
        ),
      ),
    );
  }
}
