import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
            padding: EdgeInsets.only(right: 30.0.w),
            child: Container(
              height: 70.h,
              width: 70.w,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 53, 14, 145),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Text(
                  (conductNumber + 1).toString(),
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 230.w,
                child: AutoSizeText(
                  conductType,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
              SizedBox(
                width: 230.w,
                child: AutoSizeText(
                  conductName,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0.w),
            child: const Icon(
              Icons.arrow_forward_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
