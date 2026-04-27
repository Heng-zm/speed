import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/battery_provider.dart';
import '../models/app_theme.dart';

class WattageChart extends StatelessWidget {
  final List<FlSpotData> data;

  const WattageChart({super.key, required this.data});

  // PERFORMANCE FIX: Cache the grid line styling so we don't instantiate
  // new FlLine objects for every horizontal line during the 60fps animation.
  static final _gridLine = FlLine(
    color: AppTheme.border,
    strokeWidth: 0.5,
  );

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 120);

    // Convert data to FlSpots
    final spots = data.map((d) => FlSpot(d.x, d.y)).toList();

    // CRITICAL FIX: Explicit bounds are required for the sliding window
    // since our X values increment continuously now (e.g., 100, 101, 102...)
    final double currentMinX = spots.first.x;
    final double currentMaxX = spots.last.x;

    return Container(
      height: 120,
      padding: const EdgeInsets.only(top: 8, right: 8),
      child: LineChart(
        LineChartData(
          // VISUAL FIX: Clips the animating line so it doesn't spill out
          // of the chart container while sliding left.
          clipData: const FlClipData.all(),
          minX: currentMinX,
          maxX: currentMaxX,
          minY: 10,
          maxY: 35,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (val) => _gridLine,
          ),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 32,
                getTitlesWidget: (val, meta) => Text(
                  '${val.toInt()}W',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppTheme.accent,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.accent.withOpacity(0.25),
                    AppTheme.accent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Smooth 300ms sliding animation when new data arrives
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }
}
