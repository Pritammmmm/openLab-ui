import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../report/models/report_model.dart';

class HealthScoreCard extends StatelessWidget {
  final HealthScore? healthScore;
  final StatusCounts statusCounts;

  const HealthScoreCard({
    super.key,
    this.healthScore,
    required this.statusCounts,
  });

  int get _score {
    final clientScore = _clientScore;
    if (clientScore != null) return clientScore;
    return healthScore?.score ?? 0;
  }

  int? get _clientScore {
    final total = statusCounts.total;
    if (total == 0) return null;
    final weighted = (statusCounts.green * 100) +
        (statusCounts.yellow * 20) +
        (statusCounts.red * 0);
    return (weighted / total).round();
  }

  bool get _usingServerScore =>
      statusCounts.total == 0 && healthScore?.score != null;

  String get _label =>
      _usingServerScore ? (healthScore!.label) : _fallbackLabel;

  String get _fallbackLabel {
    final score = _score;
    if (score >= 91) return 'Excellent';
    if (score >= 71) return 'Good';
    if (score >= 51) return 'Needs Attention';
    return 'Critical';
  }

  Color get scoreColor {
    final score = _score;
    if (score >= 91) return AppColors.green;
    if (score >= 71) return const Color(0xFF4CAF50);
    if (score >= 51) return AppColors.yellow;
    return AppColors.red;
  }

  Color get _cardColor => AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final score = _score;
    final cardColor = _cardColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Score',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _label,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatusDot(
                      color: AppColors.green,
                      count: statusCounts.green,
                      label: 'Normal',
                    ),
                    const SizedBox(width: 12),
                    _StatusDot(
                      color: AppColors.yellow,
                      count: statusCounts.yellow,
                      label: 'Borderline',
                    ),
                    const SizedBox(width: 12),
                    _StatusDot(
                      color: AppColors.red,
                      count: statusCounts.red,
                      label: 'High Risk',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            height: 120,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _ScoreRingPainter(
                    progress: value,
                    trackColor: Colors.white.withValues(alpha: 0.2),
                    progressColor: Colors.white,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(value * 100).round()}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Text(
                          '/ 100',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final Color color;
  final int count;
  final String label;

  const _StatusDot({
    required this.color,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _ScoreRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 5.0;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
