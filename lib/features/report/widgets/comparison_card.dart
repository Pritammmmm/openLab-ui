import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../models/parameter_model.dart';

class ComparisonCard extends StatelessWidget {
  final ParameterModel parameter;

  const ComparisonCard({super.key, required this.parameter});

  @override
  Widget build(BuildContext context) {
    final comp = parameter.comparison;
    if (comp == null) return const SizedBox.shrink();

    final statusColor = AppColors.trafficLightColor(parameter.trafficLight);
    final trendColor = _trendColor(comp.trend);

    return IntrinsicHeight(
      child: Row(
        children: [
          // Left accent strip
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: trendColor.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row + change badge
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                      if (comp.changePct != null)
                        _ChangeBadge(pct: comp.changePct!, color: trendColor),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Before / After value row
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        // Previous
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Previous',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Helpers.formatNumber(comp.previousValue),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Trend arrow
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: trendColor.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _trendIcon(comp.trend),
                              size: 18,
                              color: trendColor,
                            ),
                          ),
                        ),
                        // Current
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor.withValues(alpha: 0.7),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        Helpers.formatNumber(parameter.value),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: statusColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      parameter.unit,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            statusColor.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Change magnitude bar
                  if (comp.changePct != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child:
                          _ChangeMagnitudeBar(pct: comp.changePct!, color: trendColor),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _trendColor(String? trend) => switch (trend) {
        'improved' => AppColors.green,
        'declined' => AppColors.red,
        _ => AppColors.textMuted,
      };

  static IconData _trendIcon(String? trend) => switch (trend) {
        'improved' => Icons.trending_up_rounded,
        'declined' => Icons.trending_down_rounded,
        _ => Icons.trending_flat_rounded,
      };
}

// ─── Change badge ─────────────────────────────────────────────────────────

class _ChangeBadge extends StatelessWidget {
  final double pct;
  final Color color;

  const _ChangeBadge({required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pct > 0
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${pct.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Change magnitude bar ─────────────────────────────────────────────────

class _ChangeMagnitudeBar extends StatelessWidget {
  final double pct;
  final Color color;

  const _ChangeMagnitudeBar({required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    final magnitude = pct.abs().clamp(0.0, 100.0) / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2.5),
          child: SizedBox(
            height: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth,
                      color: color.withValues(alpha: 0.06),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      width: constraints.maxWidth * magnitude,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.5),
                            color.withValues(alpha: 0.25),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${pct.abs().toStringAsFixed(1)}% change from previous',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
