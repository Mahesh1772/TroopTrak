import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyledText extends StatelessWidget {
  const StyledText(this.text, this.fontSize, {super.key});

  final String text;
  final double fontSize;

  @override
  Widget build(context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        color: Colors.white,
      ),
    );
  }
}
