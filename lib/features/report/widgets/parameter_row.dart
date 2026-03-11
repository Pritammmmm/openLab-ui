import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/traffic_light_badge.dart';
import '../models/parameter_model.dart';

class ParameterRow extends StatelessWidget {
  final ParameterModel parameter;
  final VoidCallback? onTap;

  const ParameterRow({
    super.key,
    required this.parameter,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            TrafficLightDot(status: parameter.trafficLight),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parameter.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (parameter.aiExplanation != null)
                    Text(
                      parameter.aiExplanation!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${Helpers.formatNumber(parameter.value)} ${parameter.unit}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.trafficLightColor(
                            parameter.trafficLight),
                      ),
                ),
                if (parameter.refRange != null)
                  Text(
                    parameter.refRange!.displayRange,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                  ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
