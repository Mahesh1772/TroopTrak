import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/conduct_tracker_screen/util/charts/bar_graph/bar_data.dart';

class BarGraphStyling extends StatelessWidget {
  final conductList;
  BarGraphStyling({super.key, required this.conductList});

  List<double> participationStrength = [];

  void populate() {
    for (var conduct in conductList) {
      participationStrength.add(conduct['participants'].length.toDouble());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<double> conductParticipations = [
      49,
      54,
      64,
    ];

    Widget getTitles(double value, TitleMeta meta) {
      final style = GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      );
      String text;
      switch (value.toInt()) {
        case 0:
          text = 'RM 4';
          break;
        case 1:
          text = 'Fartlek 2';
          break;
        case 2:
          text = 'S&P 5';
          break;
        case 3:
          text = 'IPPT 2';
          break;
        case 4:
          text = 'TABATAR';
          break;

        default:
          text = '';
          break;
      }
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: SizedBox(
            height: 90,
            child: AutoSizeText(
              text,
              style: style,
              maxLines: 1,
              minFontSize: 20,
            )),
      );
    }

    //initialize bar data

    BarData myBarData =
        BarData(conductParticipationList: participationStrength);
    myBarData.initializeBarData();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: 100,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white),
        ),
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true, getTitlesWidget: getTitles, reservedSize: 30),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: myBarData.barData
            .map(
              (data) => BarChartGroupData(
                x: data.x,
                barRods: [
                  BarChartRodData(
                    toY: data.y,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 72, 30, 229),
                        Color.fromARGB(255, 130, 60, 229),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    width:
                        (200 * (1 / conductParticipations.length.toDouble())).w,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
                showingTooltipIndicators: [0],
              ),
            )
            .toList(),
      ),
    );
  }
}
