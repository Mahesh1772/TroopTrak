import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/theme_context.dart';
import '../providers/conduct_tracker_provider.dart';

/// Rebuild of `bar_graph_styling.dart`: participants per conduct (R13), each
/// bar labelled with its conduct name and count.
class ParticipationChart extends StatelessWidget {
  const ParticipationChart({super.key, required this.bars, required this.maxY});

  final List<ParticipationBar> bars;
  final double maxY;

  @override
  Widget build(BuildContext context) {
    final text = context.textStyles;
    final palette = context.palette;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: maxY == 0 ? 1 : maxY,
        minY: 0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: context.colors.tertiary),
        ),
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 4,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(rod.toY.round().toString(),
                    text.headlineMedium ?? const TextStyle()),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.sp,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                space: 2,
                child: SizedBox(
                  width: (300 / bars.length).w,
                  child: AutoSizeText(
                    bars[value.toInt()].label,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: text.titleSmall,
                  ),
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        barGroups: [
          for (var i = 0; i < bars.length; i++)
            BarChartGroupData(
              x: i,
              showingTooltipIndicators: const [0],
              barRods: [
                BarChartRodData(
                  toY: bars[i].participants.toDouble(),
                  width: (200 / bars.length).w,
                  borderRadius: BorderRadius.circular(AppRadii.sm.r / 2),
                  gradient: LinearGradient(
                    colors: palette.headerGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
