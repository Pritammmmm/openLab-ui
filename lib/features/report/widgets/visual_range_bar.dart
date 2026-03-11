import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../models/parameter_model.dart';

class VisualRangeBar extends StatelessWidget {
  final double value;
  final ReferenceRange refRange;
  final String status;

  const VisualRangeBar({
    super.key,
    required this.value,
    required this.refRange,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: CustomPaint(
        size: const Size(double.infinity, 72),
        painter: _RangeBarPainter(
          value: value,
          refMin: refRange.min,
          refMax: refRange.max,
          status: status,
        ),
      ),
    );
  }
}

class _RangeBarPainter extends CustomPainter {
  final double value;
  final double? refMin;
  final double? refMax;
  final String status;

  _RangeBarPainter({
    required this.value,
    this.refMin,
    this.refMax,
    required this.status,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barHeight = 24.0;
    final barTop = 28.0;
    final barBottom = barTop + barHeight;
    final barRect = Rect.fromLTWH(0, barTop, size.width, barHeight);
    final barRadius = Radius.circular(barHeight / 2);

    // Calculate display range with padding
    final effectiveMin = refMin ?? 0;
    final effectiveMax = refMax ?? (value * 2);
    final range = effectiveMax - effectiveMin;
    final displayMin = effectiveMin - range * 0.5;
    final displayMax = effectiveMax + range * 0.5;
    final displayRange = displayMax - displayMin;

    double normalize(double v) {
      if (displayRange == 0) return 0.5;
      return ((v - displayMin) / displayRange).clamp(0.0, 1.0);
    }

    // Draw the full bar background (gray)
    final bgPaint = Paint()..color = const Color(0xFFE8EAED);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, barRadius),
      bgPaint,
    );

    // Draw colored zones
    // Low zone (left of normal) - light red
    if (refMin != null) {
      final lowEnd = normalize(refMin!) * size.width;
      if (lowEnd > 0) {
        canvas.save();
        canvas.clipRRect(RRect.fromRectAndRadius(barRect, barRadius));
        final lowPaint = Paint()..color = AppColors.redBg;
        canvas.drawRect(
          Rect.fromLTWH(0, barTop, lowEnd, barHeight),
          lowPaint,
        );
        canvas.restore();
      }
    }

    // Normal zone (green)
    if (refMin != null || refMax != null) {
      final normalStart = refMin != null ? normalize(refMin!) * size.width : 0.0;
      final normalEnd =
          refMax != null ? normalize(refMax!) * size.width : size.width;

      canvas.save();
      canvas.clipRRect(RRect.fromRectAndRadius(barRect, barRadius));
      final normalPaint = Paint()..color = AppColors.greenBg;
      canvas.drawRect(
        Rect.fromLTWH(normalStart, barTop, normalEnd - normalStart, barHeight),
        normalPaint,
      );

      // Green border lines for normal zone
      final borderPaint = Paint()
        ..color = AppColors.green.withValues(alpha: 0.4)
        ..strokeWidth = 1.5;

      if (refMin != null && normalStart > 0) {
        canvas.drawLine(
          Offset(normalStart, barTop),
          Offset(normalStart, barBottom),
          borderPaint,
        );
      }
      if (refMax != null && normalEnd < size.width) {
        canvas.drawLine(
          Offset(normalEnd, barTop),
          Offset(normalEnd, barBottom),
          borderPaint,
        );
      }
      canvas.restore();
    }

    // High zone (right of normal) - light red
    if (refMax != null) {
      final highStart = normalize(refMax!) * size.width;
      if (highStart < size.width) {
        canvas.save();
        canvas.clipRRect(RRect.fromRectAndRadius(barRect, barRadius));
        final highPaint = Paint()..color = AppColors.redBg;
        canvas.drawRect(
          Rect.fromLTWH(highStart, barTop, size.width - highStart, barHeight),
          highPaint,
        );
        canvas.restore();
      }
    }

    // "Normal Range" label in the green zone
    if (refMin != null && refMax != null) {
      final normalStart = normalize(refMin!) * size.width;
      final normalEnd = normalize(refMax!) * size.width;
      final normalCenter = (normalStart + normalEnd) / 2;

      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Normal',
          style: TextStyle(
            color: AppColors.green.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      if (normalEnd - normalStart > textPainter.width + 8) {
        textPainter.paint(
          canvas,
          Offset(
            normalCenter - textPainter.width / 2,
            barTop + (barHeight - textPainter.height) / 2,
          ),
        );
      }
    }

    // Draw the marker (triangle + line)
    final markerX = normalize(value) * size.width;
    final markerColor = AppColors.trafficLightColor(status);

    // Vertical line through bar
    final linePaint = Paint()
      ..color = markerColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(markerX, barTop - 2),
      Offset(markerX, barBottom + 2),
      linePaint,
    );

    // Triangle marker above bar
    final trianglePath = Path()
      ..moveTo(markerX, barTop - 4)
      ..lineTo(markerX - 7, barTop - 14)
      ..lineTo(markerX + 7, barTop - 14)
      ..close();
    final trianglePaint = Paint()..color = markerColor;
    canvas.drawPath(trianglePath, trianglePaint);

    // Value label above triangle
    final valuePainter = TextPainter(
      text: TextSpan(
        text: _formatValue(value),
        style: TextStyle(
          color: markerColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelX = (markerX - valuePainter.width / 2)
        .clamp(0.0, size.width - valuePainter.width);
    valuePainter.paint(canvas, Offset(labelX, 0));

    // Min/Max labels below bar
    if (refMin != null) {
      final minPainter = TextPainter(
        text: TextSpan(
          text: _formatValue(refMin!),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final minX = normalize(refMin!) * size.width;
      minPainter.paint(
        canvas,
        Offset(
          (minX - minPainter.width / 2).clamp(0.0, size.width - minPainter.width),
          barBottom + 6,
        ),
      );
    }

    if (refMax != null) {
      final maxPainter = TextPainter(
        text: TextSpan(
          text: _formatValue(refMax!),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final maxX = normalize(refMax!) * size.width;
      maxPainter.paint(
        canvas,
        Offset(
          (maxX - maxPainter.width / 2).clamp(0.0, size.width - maxPainter.width),
          barBottom + 6,
        ),
      );
    }
  }

  String _formatValue(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(covariant _RangeBarPainter oldDelegate) {
    return value != oldDelegate.value ||
        refMin != oldDelegate.refMin ||
        refMax != oldDelegate.refMax ||
        status != oldDelegate.status;
  }
}
