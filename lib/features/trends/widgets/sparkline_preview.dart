import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../data/trends_repository.dart';

/// Mini sparkline card for the home screen — shows one parameter's trend.
class SparklinePreview extends StatelessWidget {
  final TrendParameter? trend;
  final bool isLoading;
  final VoidCallback? onTap;

  const SparklinePreview({
    super.key,
    this.trend,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? _buildLoading()
            : trend == null || trend!.dataPoints.length < 3
                ? _buildEmpty()
                : _buildSparkline(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.trending_up_rounded,
            size: 22,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Unlock Trends',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload 3+ reports to\ntrack your progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textMuted.withValues(alpha: 0.8),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSparkline() {
    final data = trend!;
    final points = data.dataPoints;
    final latest = points.last;

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final values = points.map((p) => p.value).toList();
    if (data.refMin != null) values.add(data.refMin!);
    if (data.refMax != null) values.add(data.refMax!);
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.show_chart_rounded, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                data.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16,
                color: AppColors.textMuted.withValues(alpha: 0.6)),
          ],
        ),
        const SizedBox(height: 2),
        // Value
        Text(
          '${_formatValue(latest.value)} ${data.unit}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        // Sparkline
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              rangeAnnotations: RangeAnnotations(
                horizontalRangeAnnotations: [
                  if (data.refMin != null && data.refMax != null)
                    HorizontalRangeAnnotation(
                      y1: data.refMin!,
                      y2: data.refMax!,
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                ],
              ),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: AppColors.textPrimary,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, index) {
                      final isLast = index == points.length - 1;
                      return FlDotCirclePainter(
                        radius: isLast ? 3.5 : 2,
                        color: isLast ? AppColors.textPrimary : AppColors.textMuted,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.black.withValues(alpha: 0.04),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Footer
        Text(
          '${points.length} reports',
          style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
        ),
      ],
    );
  }

  String _formatValue(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
