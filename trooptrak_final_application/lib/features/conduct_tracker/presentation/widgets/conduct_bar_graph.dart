import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/conduct.dart';

class ConductBarGraph extends StatelessWidget {
  final List<Conduct> conducts;
  final List<double> participationStrength;

  const ConductBarGraph({
    super.key,
    required this.conducts,
    required this.participationStrength,
  });

  double _calculateMaxY() {
    if (participationStrength.isEmpty) return 5.0; // Default max when no data
    double maxParticipants = participationStrength.reduce((a, b) => a > b ? a : b);
    // Add 2 to the max value to ensure bars don't reach the top
    return maxParticipants + 2.0;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: EdgeInsets.all(16.0.sp),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: _calculateMaxY(),
            minY: 0,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            ),
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                direction: TooltipDirection.top,
                tooltipMargin: 4,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    rod.toY.round().toString(),
                    GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => _buildTitle(value, meta, context),
                  reservedSize: 30.sp,
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: _createBarGroups(),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double value, TitleMeta meta, BuildContext context) {
    if (value.toInt() >= conducts.length) return const SizedBox.shrink();
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 2,
      fitInside: const SideTitleFitInsideData(
        enabled: true,
        axisPosition: 20,
        parentAxisSize: 50,
        distanceFromEdge: -10,
      ),
      child: SizedBox(
        child: AutoSizeText(
          conducts[value.toInt()].conductName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          maxLines: 1,
          wrapWords: false,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    return List.generate(
      conducts.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: participationStrength[index],
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 72, 30, 229),
                Color.fromARGB(255, 130, 60, 229),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            width: (200 * (1 / participationStrength.length)).w,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    );
  }
} 