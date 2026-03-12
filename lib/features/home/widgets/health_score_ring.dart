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

  int get _score => healthScore?.score ?? _fallbackScore;

  int get _fallbackScore {
    final total = statusCounts.total;
    if (total == 0) return 0;
    return ((statusCounts.green * 100) / total).round();
  }

  bool get _usingServerScore => healthScore?.score != null;

  String get _label => _usingServerScore
      ? (healthScore!.label)
      : _fallbackLabel;

  String get _fallbackLabel {
    final score = _score;
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Fair';
    if (score >= 40) return 'Needs Attention';
    return 'Critical';
  }

  Color get _scoreColor {
    final score = _score;
    if (score >= 80) return AppColors.green;
    if (score >= 60) return AppColors.yellow;
    return AppColors.red;
  }

  String get _subtitle {
    final coverage = healthScore?.coverage;
    if (coverage != null && coverage.found > 0) {
      if (coverage.sufficient) {
        return 'Based on ${coverage.found} key markers';
      }
      return 'Limited data — ${coverage.found} of ${coverage.total} key markers';
    }
    return 'Based on ${statusCounts.total} parameters';
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _ScoreRingPainter(
                    progress: value,
                    color: _scoreColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(value * 100).round()}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '/ 100',
                          style: TextStyle(
                            fontSize: 15,
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
          const SizedBox(height: 20),
          const Text(
            'HEALTH SCORE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _label,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _scoreColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),

          // Category breakdown
          if (healthScore != null &&
              healthScore!.categoryScores.any((c) => c.score != null)) ...[
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),
            ...healthScore!.categoryScores
                .where((c) => c.score != null)
                .map((c) => _CategoryRow(category: c)),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryScore category;

  const _CategoryRow({required this.category});

  Color get _color {
    switch (category.status) {
      case 'green':
        return AppColors.green;
      case 'yellow':
        return AppColors.yellow;
      case 'red':
        return AppColors.red;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '${category.score}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _color,
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
    final radius = size.width / 2 - 14;
    const strokeWidth = 12.0;
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
