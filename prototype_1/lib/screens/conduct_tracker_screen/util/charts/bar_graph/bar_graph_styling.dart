import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prototype_1/screens/conduct_tracker_screen/util/charts/bar_graph/bar_data.dart';

class BarGraphStyling extends StatefulWidget {
  final List<Map<String, dynamic>> conductList;
  List<double> participationStrength = [];
 BarGraphStyling(
      {super.key,
      required this.conductList,
      required this.participationStrength});

  @override
  State<BarGraphStyling> createState() => _BarGraphStylingState();
}

class _BarGraphStylingState extends State<BarGraphStyling> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Widget getTitles(double value, TitleMeta meta) {
      final style = GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      );
      String text;
      switch (value.toInt()) {
        case 0:
          text = widget.conductList[0]['conductName'];
          break;
        case 1:
          text = widget.conductList[1]['conductName'];
          break;
        case 2:
          text = widget.conductList[2]['conductName'];
          break;
        case 3:
          text = widget.conductList[3]['conductName'];
          break;
        case 4:
          text = widget.conductList[4]['conductName'];
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
        BarData(conductParticipationList: widget.participationStrength);
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
                        (200 * (1 / widget.participationStrength.length.toDouble())).w,
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
