import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/conduct.dart';

class ConductBarGraph extends StatefulWidget {
  final List<Conduct> conducts;
  final List<double> participationStrength;

  const ConductBarGraph({
    super.key,
    required this.conducts,
    required this.participationStrength,
  });

  @override
  State<ConductBarGraph> createState() => _ConductBarGraphState();
}

class _ConductBarGraphState extends State<ConductBarGraph> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  static const int visibleBars = 3;  // Show exactly 3 bars at a time
  bool showScrollIndicator = false;
  late AnimationController _peekController;
  
  @override
  void initState() {
    super.initState();
    _peekController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        showScrollIndicator = widget.conducts.length > visibleBars;
      });
      if (showScrollIndicator) {
        _startPeekAnimation();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _peekController.dispose();
    super.dispose();
  }

  void _startPeekAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      final maxScroll = _scrollController.position.maxScrollExtent;
      _peekController.addListener(() {
        if (!mounted) return;
        
        // Create a peek effect using a sine wave
        final peekOffset = (maxScroll * 0.2) * // Peek 20% of the total scroll
            (sin(_peekController.value * 2 * pi) * 0.5 + 0.5); // Smooth sine wave
        
        _scrollController.jumpTo(peekOffset);
      });

      _peekController.forward().then((_) {
        if (!mounted) return;
        _peekController.reset();
        // Smoothly scroll back to start
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  void didUpdateWidget(ConductBarGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.conducts.length != oldWidget.conducts.length) {
      setState(() {
        showScrollIndicator = widget.conducts.length > visibleBars;
      });
      if (showScrollIndicator && !_peekController.isAnimating) {
        _startPeekAnimation();
      }
    }
  }

  double _calculateMaxY() {
    if (widget.participationStrength.isEmpty) return 5.0;
    double maxParticipants = widget.participationStrength.reduce((a, b) => a > b ? a : b);
    return maxParticipants + 2.0;
  }

  double _calculateBarWidth(BuildContext context) {
    final availableWidth = MediaQuery.of(context).size.width - 32.w - 48.w;
    return (availableWidth / 3) - 16.w;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final barWidth = _calculateBarWidth(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participation Overview',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Strength distribution across conducts',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14.sp,
              letterSpacing: 0.5,
            ),
          ),
          if (showScrollIndicator) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? const Color.fromARGB(255, 45, 50, 65)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                            ? Colors.black.withOpacity(0.3) 
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 8.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe_rounded,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Scroll to see more',
                        style: GoogleFonts.poppins(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: max(
                MediaQuery.of(context).size.width - 32.w,
                (barWidth + 16.w) * widget.conducts.length + 16.w,
              ),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    maxY: _calculateMaxY(),
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.1) 
                            : Colors.black.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        direction: TooltipDirection.top,
                        tooltipMargin: 4,
                        tooltipPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        tooltipBorder: BorderSide(
                          color: isDarkMode 
                              ? Colors.white.withOpacity(0.1) 
                              : Colors.black.withOpacity(0.1),
                        ),
                        tooltipRoundedRadius: 8.r,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.round()} participants',
                            GoogleFonts.poppins(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
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
                          reservedSize: 40.sp,
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value == value.roundToDouble()) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.poppins(
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 24.w,
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: _createBarGroups(context, barWidth),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 300),
                  swapAnimationCurve: Curves.easeInOut,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(double value, TitleMeta meta, BuildContext context) {
    if (value.toInt() >= widget.conducts.length) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.h,
      child: SizedBox(
        width: 60.w,
        child: AutoSizeText(
          widget.conducts[value.toInt()].conductName,
          style: GoogleFonts.poppins(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
          minFontSize: 8,
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(BuildContext context, double barWidth) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return List.generate(
      widget.conducts.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: widget.participationStrength[index],
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.secondary,
                theme.colorScheme.secondary.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            width: barWidth,
            borderRadius: BorderRadius.circular(4.r),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxY(),
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    );
  }
} 