import 'package:flutter/material.dart';
import '../pages/add_conduct_screen.dart';

class AddConductButton extends StatelessWidget {
  const AddConductButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddConductScreen(),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
} 