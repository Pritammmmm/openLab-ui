import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/traffic_light_badge.dart';
import '../models/parameter_model.dart';

class ComparisonCard extends StatelessWidget {
  final ParameterModel parameter;

  const ComparisonCard({super.key, required this.parameter});

  @override
  Widget build(BuildContext context) {
    final comp = parameter.comparison;
    if (comp == null) return const SizedBox.shrink();

    final trendColor = _trendColor(comp.trend);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TrafficLightDot(status: parameter.trafficLight, size: 8),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                parameter.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Helpers.formatNumber(comp.previousValue),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        _trendIcon(comp.trend),
                        size: 16,
                        color: trendColor,
                      ),
                    ),
                    Text(
                      '${Helpers.formatNumber(parameter.value)} ${parameter.unit}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.trafficLightColor(
                                parameter.trafficLight),
                          ),
                    ),
                  ],
                ),
                if (comp.changePct != null)
                  Text(
                    Helpers.formatPercentage(comp.changePct),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: trendColor,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _trendColor(String? trend) {
    switch (trend) {
      case 'improved':
        return AppColors.green;
      case 'declined':
        return AppColors.red;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _trendIcon(String? trend) {
    switch (trend) {
      case 'improved':
        return Icons.trending_up_rounded;
      case 'declined':
        return Icons.trending_down_rounded;
      default:
        return Icons.trending_flat_rounded;
    }
  }
}
