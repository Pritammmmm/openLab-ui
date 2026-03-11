import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../data/trends_repository.dart';

class TrendChart extends StatelessWidget {
  final List<TrendDataPoint> dataPoints;
  final String unit;
  final double? refMin;
  final double? refMax;

  const TrendChart({
    super.key,
    required this.dataPoints,
    required this.unit,
    this.refMin,
    this.refMax,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('No data points'));
    }

    final spots = dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final allValues = dataPoints.map((d) => d.value).toList();
    if (refMin != null) allValues.add(refMin!);
    if (refMax != null) allValues.add(refMax!);

    final minY = allValues.reduce((a, b) => a < b ? a : b) * 0.85;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) * 1.15;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (dataPoints.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.surfaceBorder,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  Helpers.formatNumber(value),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= dataPoints.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    Helpers.formatDateShort(dataPoints[index].date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        rangeAnnotations: RangeAnnotations(
          horizontalRangeAnnotations: [
            if (refMin != null && refMax != null)
              HorizontalRangeAnnotation(
                y1: refMin!,
                y2: refMax!,
                color: AppColors.green.withValues(alpha: 0.1),
              ),
          ],
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (refMin != null)
              HorizontalLine(
                y: refMin!,
                color: AppColors.green.withValues(alpha: 0.4),
                strokeWidth: 1,
                dashArray: [5, 3],
              ),
            if (refMax != null)
              HorizontalLine(
                y: refMax!,
                color: AppColors.green.withValues(alpha: 0.4),
                strokeWidth: 1,
                dashArray: [5, 3],
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final status = dataPoints[index].status;
                return FlDotCirclePainter(
                  radius: 5,
                  color: AppColors.trafficLightColor(status),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.spotIndex;
                final dp = dataPoints[index];
                return LineTooltipItem(
                  '${Helpers.formatNumber(dp.value)} $unit\n',
                  TextStyle(
                    color: AppColors.trafficLightColor(dp.status),
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: Helpers.formatDate(dp.date),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
