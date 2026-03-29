import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/isometric_icon.dart';
import '../../../core/widgets/premium_gate.dart';
import '../../report/models/parameter_model.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_provider.dart';

class SmartAdviceSection extends ConsumerWidget {
  final List<ParameterModel> parameters;

  const SmartAdviceSection({super.key, required this.parameters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adviceParams = parameters
        .where((p) =>
            (p.trafficLight == 'red' || p.trafficLight == 'yellow') &&
            p.aiExplanation != null &&
            p.aiExplanation!.isNotEmpty)
        .toList();

    if (adviceParams.isEmpty) return const SizedBox.shrink();

    final activePlan = ref.watch(activePlanProvider);
    final isFree = activePlan == PlanTier.free;
    final visibleCount = isFree ? 1 : 3;
    final hiddenCount = adviceParams.length - visibleCount;

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
            if (isFree) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Limited',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ...adviceParams
            .take(visibleCount)
            .map((param) => _AdviceCard(parameter: param)),
        if (isFree && hiddenCount > 0)
          UpgradeTeaser(
            message:
                '$hiddenCount more insight${hiddenCount > 1 ? 's' : ''} available with Plus',
          ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
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
