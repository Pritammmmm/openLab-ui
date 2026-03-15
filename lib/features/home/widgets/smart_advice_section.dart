import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/isometric_icon.dart';
import '../../report/models/parameter_model.dart';

class SmartAdviceSection extends StatelessWidget {
  final List<ParameterModel> parameters;

  const SmartAdviceSection({super.key, required this.parameters});

  @override
  Widget build(BuildContext context) {
    final adviceParams = parameters
        .where((p) =>
            (p.trafficLight == 'red' || p.trafficLight == 'yellow') &&
            p.aiExplanation != null &&
            p.aiExplanation!.isNotEmpty)
        .toList();

    if (adviceParams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
                Icons.lightbulb_rounded, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Smart Insights',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...adviceParams
            .take(3)
            .map((param) => _AdviceCard(parameter: param)),
      ],
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final ParameterModel parameter;

  const _AdviceCard({required this.parameter});

  @override
  Widget build(BuildContext context) {
    final isRed = parameter.trafficLight == 'red';
    final accentColor = isRed ? AppColors.red : AppColors.yellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 3, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon3D(
                          icon: isRed
                              ? Icons.warning_amber_rounded
                              : Icons.remove_red_eye_rounded,
                          color: accentColor,
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            parameter.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: accentColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      parameter.aiExplanation!,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
