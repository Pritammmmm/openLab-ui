import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../report/models/report_model.dart';

class QuickStatsRow extends StatelessWidget {
  final StatusCounts statusCounts;

  const QuickStatsRow({super.key, required this.statusCounts});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          count: statusCounts.green,
          label: 'Normal',
          color: AppColors.green,
          bgColor: AppColors.greenBg,
        ),
        const SizedBox(width: 8),
        _StatChip(
          count: statusCounts.yellow,
          label: 'Borderline',
          color: AppColors.yellow,
          bgColor: AppColors.yellowBg,
        ),
        const SizedBox(width: 8),
        _StatChip(
          count: statusCounts.red,
          label: 'Attention',
          color: AppColors.red,
          bgColor: AppColors.redBg,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bgColor;

  const _StatChip({
    required this.count,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
