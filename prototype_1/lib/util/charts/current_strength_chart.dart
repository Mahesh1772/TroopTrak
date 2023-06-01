import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/constants.dart';

class CurrentStrengthChart extends StatelessWidget {
  CurrentStrengthChart({
    super.key,
  });

  final List<PieChartSectionData> pieChartSoldierStrengthIndicators = [
    PieChartSectionData(
        color: Colors.red, value: 6, showTitle: false, radius: 25.r),
    PieChartSectionData(
        color: Colors.blue, value: 74, showTitle: false, radius: 22.r),
    PieChartSectionData(
        color: Colors.yellow, value: 25, showTitle: false, radius: 19.r),
    PieChartSectionData(
        color: Colors.lightBlueAccent,
        value: 1,
        showTitle: false,
        radius: 16.r),
    PieChartSectionData(
        color: Colors.blue.withOpacity(0.1),
        value: 44,
        showTitle: false,
        radius: 16.r),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 215.h,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
                sectionsSpace: 0,
                startDegreeOffset: -90,
                sections: pieChartSoldierStrengthIndicators),
          ),
          Positioned.fill(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: defaultPadding,
              ),
              Text(
                "79",
                style: GoogleFonts.poppins(
                  fontSize: 48.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 0.5,
                ),
              ),
              Text(
                "of 126 soldiers",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
