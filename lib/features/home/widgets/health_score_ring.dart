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
    // Weighted: green=100%, yellow=20%, red=0%
    final weighted = (statusCounts.green * 100) +
        (statusCounts.yellow * 20) +
        (statusCounts.red * 0);
    return (weighted / total).round();
  }

  bool get _usingServerScore =>
      statusCounts.total == 0 && healthScore?.score != null;

  String get _label => _usingServerScore
      ? (healthScore!.label)
      : _fallbackLabel;

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

  @override
  Widget build(BuildContext context) {
    final score = _score;
    final color = scoreColor;
    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _ScoreRingPainter(
                    progress: value,
                    color: color,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(value * 100).round()}',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1,
                          ),
                        ),
                        const Text(
                          '/ 100',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'HEALTH SCORE',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScoreRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
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
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
