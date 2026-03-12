import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../report/models/parameter_model.dart';

class KeyParametersList extends StatelessWidget {
  final List<ParameterModel> parameters;

  const KeyParametersList({super.key, required this.parameters});

  @override
  Widget build(BuildContext context) {
    final watchParams = parameters
        .where((p) => p.trafficLight == 'red' || p.trafficLight == 'yellow')
        .toList()
      ..sort((a, b) {
        if (a.trafficLight == 'red' && b.trafficLight != 'red') return -1;
        if (a.trafficLight != 'red' && b.trafficLight == 'red') return 1;
        return 0;
      });

    if (watchParams.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.visibility_rounded,
                size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 8),
            Text(
              'Parameters to Watch',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${watchParams.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...watchParams
            .take(5)
            .map((param) => _WatchParameterCard(parameter: param)),
      ],
    );
  }
}

class _WatchParameterCard extends StatelessWidget {
  final ParameterModel parameter;

  const _WatchParameterCard({required this.parameter});

  @override
  Widget build(BuildContext context) {
    final isRed = parameter.trafficLight == 'red';
    final statusColor = AppColors.trafficLightColor(parameter.trafficLight);
    final statusBg = AppColors.trafficLightBg(parameter.trafficLight);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  parameter.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isRed ? 'Abnormal' : 'Borderline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Helpers.formatNumber(parameter.value),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  parameter.unit,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              if (parameter.refRange != null)
                Text(
                  'Ref: ${parameter.refRange!.displayRange}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          if (parameter.refRange != null) ...[
            const SizedBox(height: 12),
            _CompactRangeBar(
              value: parameter.value,
              refMin: parameter.refRange!.min,
              refMax: parameter.refRange!.max,
              status: parameter.trafficLight,
            ),
          ],
          if (parameter.comparison != null) ...[
            const SizedBox(height: 10),
            _ComparisonStrip(comparison: parameter.comparison!),
          ],
        ],
      ),
    );
  }
}

class _CompactRangeBar extends StatelessWidget {
  final double value;
  final double? refMin;
  final double? refMax;
  final String status;

  const _CompactRangeBar({
    required this.value,
    this.refMin,
    this.refMax,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final effectiveMin = refMin ?? 0;
          final effectiveMax = refMax ?? (value * 2);
          final range = effectiveMax - effectiveMin;
          final displayMin = effectiveMin - range * 0.5;
          final displayMax = effectiveMax + range * 0.5;
          final displayRange = displayMax - displayMin;

          double normalize(double v) {
            if (displayRange == 0) return 0.5;
            return ((v - displayMin) / displayRange).clamp(0.0, 1.0);
          }

          final normalStart = refMin != null ? normalize(refMin!) : 0.0;
          final normalEnd = refMax != null ? normalize(refMax!) : 1.0;
          final markerPos = normalize(value);
          final markerColor = AppColors.trafficLightColor(status);

          return ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  color: const Color(0xFFE8EAED),
                ),
                Positioned(
                  left: normalStart * width,
                  width: (normalEnd - normalStart) * width,
                  top: 0,
                  bottom: 0,
                  child: Container(color: AppColors.greenBg),
                ),
                Positioned(
                  left: (markerPos * width - 3).clamp(0, width - 6),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: markerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ComparisonStrip extends StatelessWidget {
  final ComparisonInfo comparison;

  const _ComparisonStrip({required this.comparison});

  @override
  Widget build(BuildContext context) {
    final trend = comparison.trend ?? 'stable';
    final icon = trend == 'improved'
        ? Icons.trending_up_rounded
        : trend == 'declined'
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;
    final color = trend == 'improved'
        ? AppColors.green
        : trend == 'declined'
            ? AppColors.red
            : AppColors.textMuted;
    final pct = comparison.changePct;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          trend == 'stable'
              ? 'Stable'
              : '${pct != null ? '${pct.abs().toStringAsFixed(1)}% ' : ''}$trend',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        if (comparison.previousValue != null) ...[
          const SizedBox(width: 8),
          Text(
            'from ${Helpers.formatNumber(comparison.previousValue!)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
