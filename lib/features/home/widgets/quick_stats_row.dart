import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../report/models/report_model.dart';

class QuickStatsRow extends StatelessWidget {
  final StatusCounts statusCounts;

  const QuickStatsRow({super.key, required this.statusCounts});

  @override
  Widget build(BuildContext context) {
    final total = statusCounts.total;
    final greenPct = total > 0 ? (statusCounts.green / total * 100).round() : 0;
    final yellowPct = total > 0 ? (statusCounts.yellow / total * 100).round() : 0;
    final redPct = total > 0 ? (statusCounts.red / total * 100).round() : 0;

    return Row(
      children: [
        _RingStatCard(
          count: statusCounts.green,
          percent: greenPct,
          label: 'Normal',
          color: AppColors.green,
          total: total,
        ),
        const SizedBox(width: 10),
        _RingStatCard(
          count: statusCounts.yellow,
          percent: yellowPct,
          label: 'Borderline',
          color: AppColors.yellow,
          total: total,
        ),
        const SizedBox(width: 10),
        _RingStatCard(
          count: statusCounts.red,
          percent: redPct,
          label: 'Attention',
          color: AppColors.red,
          total: total,
        ),
      ],
    );
  }
}

class _RingStatCard extends StatelessWidget {
  final int count;
  final int percent;
  final String label;
  final Color color;
  final int total;

  const _RingStatCard({
    required this.count,
    required this.percent,
    required this.label,
    required this.color,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
        child: Column(
          children: [
            // Mini ring
            SizedBox(
              width: 44,
              height: 44,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: total > 0 ? count / total : 0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _MiniRingPainter(
                      progress: value,
                      color: color,
                    ),
                    child: Center(
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color,
                          height: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MiniRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 5.0;
    const startAngle = -3.14159 / 2;
    final sweepAngle = 2 * 3.14159 * progress;

    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    if (progress > 0) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniRingPainter old) =>
      old.progress != progress || old.color != color;
}
