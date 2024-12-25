import 'package:flutter/material.dart';

class NoConductsWidget extends StatelessWidget {
  const NoConductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No conducts scheduled for this date',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
} 