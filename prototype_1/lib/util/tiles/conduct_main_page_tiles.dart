import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/text_styles/text_style.dart';

class ConductTile extends StatelessWidget {
  final String conductType;
  final String conductName;
  final int conductNumber;

  const ConductTile(
      {super.key,
      required this.conductName,
      required this.conductType,
      required this.conductNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0.sp),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Container(
              height: 70.h,
              width: 70.w,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 53, 14, 145),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: AutoSizeText(
                  (conductNumber + 1).toString(),
                  minFontSize: 30,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledText(conductType, 14, fontWeight: FontWeight.w400),
              StyledText(conductName, 24, fontWeight: FontWeight.w500)
            ],
          ),
        ],
      ),
    );
  }
}
