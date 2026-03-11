import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/traffic_light_badge.dart';
import '../models/parameter_model.dart';
import '../widgets/visual_range_bar.dart';

class ParameterDetailSheet extends StatelessWidget {
  final ParameterModel parameter;

  const ParameterDetailSheet({super.key, required this.parameter});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Name + Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    parameter.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                TrafficLightBadge(status: parameter.trafficLight),
              ],
            ),
            if (parameter.category != null) ...[
              const SizedBox(height: 4),
              Text(
                parameter.category!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 24),

            // Large value display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.trafficLightBg(parameter.trafficLight),
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              child: Column(
                children: [
                  Text(
                    Helpers.formatNumber(parameter.value),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.trafficLightColor(
                              parameter.trafficLight),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    parameter.unit,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Visual Range Bar
            if (parameter.refRange != null) ...[
              Text(
                'Where you fall in the range',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              VisualRangeBar(
                value: parameter.value,
                refRange: parameter.refRange!,
                status: parameter.trafficLight,
              ),
              const SizedBox(height: 8),
              Text(
                'Normal Range: ${parameter.refRange!.displayRange} ${parameter.unit}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 24),
            ],

            // AI Explanation
            if (parameter.aiExplanation != null) ...[
              Text(
                'What does this mean?',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                parameter.aiExplanation!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
            ],

            // Comparison
            if (parameter.comparison != null) ...[
              Text(
                'Compared to Previous',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Previous',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.formatNumber(
                              parameter.comparison!.previousValue),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          Helpers.trendIcon(parameter.comparison!.trend),
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          Helpers.formatPercentage(
                              parameter.comparison!.changePct),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Current',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.formatNumber(parameter.value),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AppColors.trafficLightColor(
                                        parameter.trafficLight),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
