import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/traffic_light_badge.dart';
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: dot + name + status badge
            Row(
              children: [
                TrafficLightDot(status: parameter.trafficLight, size: 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    parameter.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TrafficLightBadge(
                  status: parameter.trafficLight,
                  fontSize: 11,
                ),
              ],
            ),

            // Subtitle: shortName · category
            if (parameter.shortName != null || parameter.category != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  [
                    if (parameter.shortName != null) parameter.shortName,
                    if (parameter.category != null) parameter.category,
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Value display
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Helpers.formatNumber(parameter.value),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      parameter.unit,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: color,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Reference range + visual bar
            if (parameter.refRange != null) ...[
              const SizedBox(height: 16),
              Text(
                _rangeLabel(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 8),
              VisualRangeBar(
                value: parameter.value,
                refRange: parameter.refRange!,
                status: parameter.trafficLight,
              ),
            ],

            // AI explanation
            if (parameter.aiExplanation != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        parameter.aiExplanation!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Comparison with previous report
            if (parameter.comparison != null &&
                parameter.comparison!.previousValue != null) ...[
              const SizedBox(height: 12),
              _ComparisonStrip(
                comparison: parameter.comparison!,
                currentValue: parameter.value,
                unit: parameter.unit,
                trafficLight: parameter.trafficLight,
              ),
            ],

            // Read more on Google
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _searchOnGoogle(),
                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                label: const Text('Read'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchOnGoogle() {
    final query = '${parameter.name} blood test';
    final url = Uri.parse('https://www.google.com/search?q=${Uri.encodeComponent(query)}');
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          // Previous value
          Text(
            Helpers.formatNumber(comparison.previousValue),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  decoration: TextDecoration.lineThrough,
                ),
          ),
          const SizedBox(width: 8),
          // Trend arrow
          Icon(
            switch (trend) {
              'improved' => Icons.trending_up_rounded,
              'declined' => Icons.trending_down_rounded,
              _ => Icons.trending_flat_rounded,
            },
            size: 18,
            color: trendColor,
          ),
          const SizedBox(width: 8),
          // Current value
          Text(
            '${Helpers.formatNumber(currentValue)} $unit',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.trafficLightColor(trafficLight),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          // Change percentage
          if (comparison.changePct != null)
            Text(
              Helpers.formatPercentage(comparison.changePct),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
        ],
      ),
    );
  }
}
