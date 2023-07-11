import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/util/constants.dart';

class CurrentStrengthChart extends StatelessWidget {
  CurrentStrengthChart({
    super.key,
    required this.currentOfficers,
    required this.currentWOSEs,
    required this.currentStatus,
    required this.currentMA,
    required this.totalOfficers,
    required this.totalWOSEs,
  });

  final int currentOfficers;
  final int currentWOSEs;
  final int currentStatus;
  final int currentMA;
  final int totalOfficers;
  final int totalWOSEs;

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> pieChartSoldierStrengthIndicators = [
      PieChartSectionData(
          color: Colors.red,
          value: currentOfficers.toDouble(),
          showTitle: false,
          radius: 25.r),
      PieChartSectionData(
          color: Colors.blue,
          value: currentWOSEs.toDouble(),
          showTitle: false,
          radius: 22.r),
      PieChartSectionData(
          color: Colors.yellow,
          value: currentStatus.toDouble(),
          showTitle: false,
          radius: 19.r),
      PieChartSectionData(
          color: Colors.lightBlueAccent,
          value: currentMA.toDouble(),
          showTitle: false,
          radius: 16.r),
      PieChartSectionData(
          color: Colors.blue.withOpacity(0.1),
          value: (totalOfficers.toDouble() +
                  totalWOSEs.toDouble() +
                  currentStatus.toDouble() +
                  currentMA.toDouble()) -
              (currentOfficers.toDouble() + currentWOSEs.toDouble()),
          showTitle: false,
          radius: 16.r),
    ];

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
                "${(currentOfficers + currentWOSEs)}",
                style: GoogleFonts.poppins(
                  fontSize: 48.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 0.5,
                ),
              ),
              Text(
                "of ${(totalOfficers + totalWOSEs)} soldiers",
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
