import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../models/reference_ranges.dart';

class RangeIndicator extends StatelessWidget {
  final RangeStatus status;
  final bool compact;

  const RangeIndicator({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }

  Color get _bgColor => switch (status) {
        RangeStatus.normal => AppColors.greenBg,
        RangeStatus.borderline => AppColors.yellowBg,
        RangeStatus.high => AppColors.redBg,
        RangeStatus.low => const Color(0xFFE3F2FD),
      };

  Color get _textColor => switch (status) {
        RangeStatus.normal => AppColors.green,
        RangeStatus.borderline => AppColors.yellow,
        RangeStatus.high => AppColors.red,
        RangeStatus.low => const Color(0xFF1976D2),
      };
}

extension RangeStatusLabel on RangeStatus {
  String get label => switch (this) {
        RangeStatus.normal => 'Normal',
        RangeStatus.borderline => 'Borderline',
        RangeStatus.high => 'High',
        RangeStatus.low => 'Low',
      };
}
