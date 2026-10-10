import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context.dart';
import '../../domain/entities/strength_summary.dart';

/// Rebuild of `current_strength_chart.dart`: four rings and the in-camp count.
class StrengthChart extends StatelessWidget {
  const StrengthChart({super.key, required this.summary});

  final StrengthSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final officers = s.officersInCamp.length.toDouble();
    final woses = s.wosesInCamp.length.toDouble();
    final status = s.onStatus.length.toDouble();
    final ma = s.onMa.length.toDouble();
    final rest = s.total + status + ma - (officers + woses);
    PieChartSectionData ring(Color color, double value, double radius) =>
        PieChartSectionData(
            color: color, value: value, showTitle: false, radius: radius.r);
    final text = context.textStyles;
    return SizedBox(
      height: 215.h,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              startDegreeOffset: -90,
              sections: [
                ring(AppColors.chartOfficers, officers, 25),
                ring(AppColors.chartWoses, woses, 22),
                ring(AppColors.chartStatus, status, 19),
                ring(AppColors.chartMedical, ma, 16),
                ring(AppColors.chartRemainder, rest > 0 ? rest : 1, 16),
              ],
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${(officers + woses).toInt()}',
                    key: const Key('inCampCount'),
                    style: text.displayLarge?.copyWith(height: 0.9)),
                Text('of ${s.total} soldiers', style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
