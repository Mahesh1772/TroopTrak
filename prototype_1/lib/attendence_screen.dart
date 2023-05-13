import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularPercentIndicator(
                animation: true,
                animationDuration: 2000,
                radius: 150,
                lineWidth: 25,
                percent: 0.8,
                progressColor: Colors.deepPurple,
                backgroundColor: Colors.deepPurple.shade200,
                circularStrokeCap: CircularStrokeCap.round,
                center: const Icon(
                  Icons.people_outline,
                  size: 150,
                ),
              ),
              Text(
                'Strength In-Camp: 80%',
                style: GoogleFonts.kanit(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
