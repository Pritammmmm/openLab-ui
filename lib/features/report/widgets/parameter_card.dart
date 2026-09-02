import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../models/parameter_model.dart';
import 'visual_range_bar.dart';

class ParameterCard extends StatelessWidget {
  final ParameterModel parameter;
  final int? age;

  const ParameterCard({
    super.key,
    required this.parameter,
    this.age,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.trafficLightColor(parameter.trafficLight);
    final bgColor = AppColors.trafficLightBg(parameter.trafficLight);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parameter.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (parameter.shortName != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        parameter.shortName!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Helpers.formatNumber(parameter.value),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      parameter.unit,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: color.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (parameter.refRange != null) ...[
            const SizedBox(height: 14),
            Text(
              _rangeLabel(),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            VisualRangeBar(
              value: parameter.value,
              refRange: parameter.refRange!,
              status: parameter.trafficLight,
            ),
          ],

          if (parameter.aiExplanation != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      parameter.aiExplanation!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (parameter.comparison != null &&
              parameter.comparison!.previousValue != null) ...[
            const SizedBox(height: 10),
            _ComparisonStrip(
              comparison: parameter.comparison!,
              currentValue: parameter.value,
              unit: parameter.unit,
              trafficLight: parameter.trafficLight,
            ),
          ],

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _searchOnGoogle,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 13,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Learn more',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _searchOnGoogle() {
    final query = '${parameter.name} blood test';
    final url = Uri.parse(
        'https://www.google.com/search?q=${Uri.encodeComponent(query)}');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  String _rangeLabel() {
    final range = parameter.refRange!;
    final rangeText = range.displayRange;
    if (age != null && age! > 0) {
      return 'Normal range (Age $age): $rangeText ${parameter.unit}';
    }
    return 'Normal range: $rangeText ${parameter.unit}';
  }
}

// ─── Comparison strip ─────────────────────────────────────────────────────

class _ComparisonStrip extends StatelessWidget {
  final ComparisonInfo comparison;
  final double currentValue;
  final String unit;
  final String trafficLight;

  const _ComparisonStrip({
    required this.comparison,
    required this.currentValue,
    required this.unit,
    required this.trafficLight,
  });

  @override
  Widget build(BuildContext context) {
    final trend = comparison.trend;
    final trendColor = switch (trend) {
      'improved' => AppColors.green,
      'declined' => AppColors.red,
      _ => AppColors.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: trendColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Text(
            Helpers.formatNumber(comparison.previousValue),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            switch (trend) {
              'improved' => Icons.trending_up_rounded,
              'declined' => Icons.trending_down_rounded,
              _ => Icons.trending_flat_rounded,
            },
            size: 16,
            color: trendColor,
          ),
          const SizedBox(width: 8),
          Text(
            '${Helpers.formatNumber(currentValue)} $unit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.trafficLightColor(trafficLight),
            ),
          ),
          const Spacer(),
          if (comparison.changePct != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: trendColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                Helpers.formatPercentage(comparison.changePct),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: trendColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
