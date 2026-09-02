import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../data/trends_repository.dart';

class SparklinePreview extends StatefulWidget {
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
  State<SparklinePreview> createState() => _SparklinePreviewState();
}

class _SparklinePreviewState extends State<SparklinePreview>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (_isSinglePoint) {
      _shimmerController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  bool get _isSinglePoint =>
      widget.trend != null && widget.trend!.dataPoints.length == 1;

  @override
  void didUpdateWidget(covariant SparklinePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isSinglePoint) {
      if (!_shimmerController.isAnimating) _shimmerController.repeat();
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _shimmerController.stop();
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: widget.isLoading
            ? _buildLoading()
            : widget.trend == null || widget.trend!.dataPoints.isEmpty
                ? _buildEmpty()
                : widget.trend!.dataPoints.length == 1
                    ? _buildPremiumSingle()
                    : _buildSparkline(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildEmpty() {
    final isUnlocked = widget.onTap != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUnlocked ? Icons.show_chart_rounded : Icons.trending_up_rounded,
            size: 22,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isUnlocked ? 'View Trends' : 'Unlock Trends',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isUnlocked
              ? 'Tap to explore your\nparameter trends'
              : 'Upload 3+ reports to\ntrack your progress',
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

  Widget _buildPremiumSingle() {
    final data = widget.trend!;
    final point = data.dataPoints.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.show_chart_rounded,
                  size: 12, color: AppColors.primary),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                data.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: _formatValue(point.value),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: ' ${data.unit}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: Listenable.merge([_shimmerController, _pulseController]),
              builder: (context, child) {
                return SizedBox.expand(
                  child: CustomPaint(
                    painter: _PremiumCurvePainter(
                      shimmerProgress: _shimmerController.value,
                      pulseValue: _pulseController.value,
                      primaryColor: AppColors.primary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Upload more to see trends',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted.withValues(alpha: 0.6),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _statusColor(double value, double? refMin, double? refMax) {
    if (refMin != null && value < refMin) return AppColors.red;
    if (refMax != null && value > refMax) return AppColors.red;
    if (refMin != null && refMax != null) {
      final range = refMax - refMin;
      if (range > 0) {
        final margin = range * 0.1;
        if (value < refMin + margin || value > refMax - margin) {
          return AppColors.yellow;
        }
      }
    }
    return AppColors.green;
  }

  Widget _buildSparkline() {
    final data = widget.trend!;
    final points = data.dataPoints;
    final latest = points.last;

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final dotColors = points
        .map((p) => _statusColor(p.value, data.refMin, data.refMax))
        .toList();

    final values = points.map((p) => p.value).toList();
    if (data.refMin != null) values.add(data.refMin!);
    if (data.refMax != null) values.add(data.refMax!);
    final minY = values.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.show_chart_rounded,
                size: 14, color: AppColors.textMuted),
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
            Icon(Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.textMuted.withValues(alpha: 0.6)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${_formatValue(latest.value)} ${data.unit}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
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
                      color: AppColors.green.withValues(alpha: 0.06),
                    ),
                ],
              ),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.35,
                  color: Colors.black,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, bar, index) {
                      final color = dotColors[index];
                      return FlDotCirclePainter(
                        radius: 4,
                        color: color,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
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

class _PremiumCurvePainter extends CustomPainter {
  final double shimmerProgress;
  final double pulseValue;
  final Color primaryColor;

  _PremiumCurvePainter({
    required this.shimmerProgress,
    required this.pulseValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Build a smooth bezier curve path
    final path = Path();
    path.moveTo(0, h * 0.7);
    path.cubicTo(
      w * 0.15, h * 0.55,
      w * 0.25, h * 0.3,
      w * 0.38, h * 0.45,
    );
    path.cubicTo(
      w * 0.5, h * 0.58,
      w * 0.58, h * 0.65,
      w * 0.68, h * 0.35,
    );
    path.cubicTo(
      w * 0.78, h * 0.08,
      w * 0.88, h * 0.18,
      w, h * 0.25,
    );

    // Gradient fill below the curve
    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, h),
        [
          primaryColor.withValues(alpha: 0.08),
          primaryColor.withValues(alpha: 0.0),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Main curve line with gradient
    final linePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(w, 0),
        [
          primaryColor.withValues(alpha: 0.3),
          primaryColor.withValues(alpha: 0.7),
          primaryColor,
        ],
        [0.0, 0.5, 1.0],
      )
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Shimmer sweep overlay on the line
    final shimmerX = shimmerProgress * (w + 60) - 30;
    final shimmerPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(shimmerX - 30, 0),
        Offset(shimmerX + 30, 0),
        [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0.0),
        ],
        [0.0, 0.5, 1.0],
      )
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, shimmerPaint);

    // Pulsing dot at the endpoint
    final endX = w;
    final endY = h * 0.25;
    final pulseRadius = 3.5 + pulseValue * 2.5;
    final glowRadius = 8.0 + pulseValue * 6.0;

    // Outer glow
    canvas.drawCircle(
      Offset(endX, endY),
      glowRadius,
      Paint()..color = primaryColor.withValues(alpha: 0.08 + pulseValue * 0.08),
    );

    // White border
    canvas.drawCircle(
      Offset(endX, endY),
      pulseRadius + 2,
      Paint()..color = Colors.white,
    );

    // Filled dot
    canvas.drawCircle(
      Offset(endX, endY),
      pulseRadius,
      Paint()..color = primaryColor,
    );

    // Three subtle horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;
    for (final frac in [0.25, 0.5, 0.75]) {
      canvas.drawLine(
        Offset(0, h * frac),
        Offset(w, h * frac),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumCurvePainter old) =>
      old.shimmerProgress != shimmerProgress || old.pulseValue != pulseValue;
}
