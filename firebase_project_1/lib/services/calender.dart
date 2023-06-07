import 'package:flutter/material.dart';

class Calender extends StatefulWidget {
  const Calender({super.key});

  @override
  State<Calender> createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Center(
          child: Text(
            textAlign: TextAlign.justify,
            'Calender display',
            style: TextStyle(
              fontSize: 30,
              color: Colors.tealAccent.shade400,
            ),
          ),
        ),
      ),
    );
  }
}
