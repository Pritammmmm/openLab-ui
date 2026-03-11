import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../utils/helpers.dart';

class TrafficLightBadge extends StatelessWidget {
  final String status;
  final String? label;
  final int? count;
  final double fontSize;

  const TrafficLightBadge({
    super.key,
    required this.status,
    this.label,
    this.count,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.trafficLightColor(status);
    final bgColor = AppColors.trafficLightBg(status);
    final displayText = label ?? (count != null
        ? '$count ${Helpers.statusLabel(status)}'
        : Helpers.statusLabel(status));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
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
          const SizedBox(width: 6),
          Text(
            displayText,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class TrafficLightDot extends StatelessWidget {
  final String status;
  final double size;

  const TrafficLightDot({
    super.key,
    required this.status,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.trafficLightColor(status),
        shape: BoxShape.circle,
      ),
    );
  }
}

class OverallStatusCircle extends StatelessWidget {
  final String status;
  final double size;

  const OverallStatusCircle({
    super.key,
    required this.status,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.trafficLightColor(status);
    final bgColor = AppColors.trafficLightBg(status);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 3),
      ),
      child: Icon(
        _iconForStatus(status),
        color: color,
        size: size * 0.45,
      ),
    );
  }

  IconData _iconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'green':
      case 'normal':
        return Icons.check_rounded;
      case 'yellow':
      case 'borderline':
        return Icons.warning_amber_rounded;
      case 'red':
      case 'abnormal':
      case 'attention':
        return Icons.priority_high_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
