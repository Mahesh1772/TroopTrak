import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SoldierDetailedInfoTemplate extends StatelessWidget {
  const SoldierDetailedInfoTemplate({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.isToggled,
  });

  final String title;
  final String content;
  final IconData? icon;
  final bool isToggled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30.0.w, right: 30.0.w, top: 30.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 30.sp,
            color: isToggled ? Colors.white : Colors.black,
          ),
          SizedBox(
            width: 20.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: isToggled ? Colors.white : Colors.black,
                ),
              ),
              Text(
                content,
                maxLines: 2,
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isToggled ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
