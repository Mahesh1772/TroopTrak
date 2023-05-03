import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyledText extends StatelessWidget {
  const StyledText(this.text, {super.key});

  final String text;
  @override
  Widget build(context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.kanit(
        fontSize: 25,
        color: const Color.fromARGB(255, 59, 8, 47),
      ),
    );
  }
}
