import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/conduct.dart';

class ConductBarGraph extends StatelessWidget {
  final List<Conduct> conducts;
  final List<double> participationStrength;

  const ConductBarGraph({
    super.key,
    required this.conducts,
    required this.participationStrength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200, // Reduced height
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: participationStrength.isEmpty ? 1 : participationStrength.reduce(max),
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => _buildTitle(value, context),
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: _createBarGroups(),
        ),
      ),
    );
  }

  Widget _buildTitle(double value, BuildContext context) {
    if (value.toInt() >= conducts.length) return const SizedBox.shrink();
    
    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      space: 2,
      child: Text(
        conducts[value.toInt()].conductName,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
            width: 200 * (1 / participationStrength.length),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    );
  }
} 