import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyledText extends StatelessWidget {
  const StyledText(this.text, this.fontSize,
      {super.key, required this.fontWeight});

  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: Colors.white,
      ),
    );
  }
}
