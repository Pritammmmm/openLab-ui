import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_theme.dart';
import '../data/health_database.dart';
import '../models/health_metric_type.dart';
import '../models/reference_ranges.dart';
import '../providers/blood_sugar_provider.dart';
import '../widgets/health_card.dart';
import '../widgets/metric_input_field.dart';
import '../widgets/range_indicator.dart';

class BloodSugarScreen extends ConsumerWidget {
  const BloodSugarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(bloodSugarListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Blood Sugar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogSheet(context, ref),
        backgroundColor: HealthMetricType.bloodSugar.color,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: metricsAsync.when(
        data: (metrics) => _Body(metrics: metrics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Something went wrong')),
      ),
    );
  }

  void _showLogSheet(BuildContext context, WidgetRef ref) {
    final valueCtrl = TextEditingController();
    var selectedType = BloodSugarSubType.fasting;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log Blood Sugar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: BloodSugarSubType.values.map((t) {
                  final selected = t == selectedType;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? HealthMetricType.bloodSugar.color.withValues(alpha: 0.12)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? HealthMetricType.bloodSugar.color
                              : AppColors.surfaceBorder,
                        ),
                      ),
                      child: Text(
                        t.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? HealthMetricType.bloodSugar.color
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              MetricInputField(
                controller: valueCtrl,
                label: '${selectedType.label} glucose',
                unit: 'mg/dL',
                autofocus: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: HealthMetricType.bloodSugar.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    final val = double.tryParse(valueCtrl.text);
                    if (val != null && val > 0) {
                      ref.read(bloodSugarActionsProvider).log(
                            value: val,
                            subType: selectedType.name,
                          );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<HealthMetric> metrics;

  const _Body({required this.metrics});

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bloodtype_rounded,
                size: 48, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text(
              'No readings yet',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap + to log your blood sugar',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final latest = metrics.first;
    final subType = BloodSugarSubType.values.firstWhere(
      (t) => t.name == latest.subType,
      orElse: () => BloodSugarSubType.fasting,
    );
    final status = HealthRanges.evaluateBloodSugar(latest.value, subType);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _LatestReadingCard(metric: latest, status: status, subType: subType),
        const SizedBox(height: 24),
        const Text(
          'History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...metrics.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReadingTile(metric: m),
            )),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _LatestReadingCard extends StatelessWidget {
  final HealthMetric metric;
  final RangeStatus status;
  final BloodSugarSubType subType;

  const _LatestReadingCard({
    required this.metric,
    required this.status,
    required this.subType,
  });

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Latest Reading',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              RangeIndicator(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${metric.value.toInt()}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'mg/dL',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${subType.label} · ${DateFormat('MMM d, h:mm a').format(metric.recordedAt)}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  final HealthMetric metric;

  const _ReadingTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    final subType = BloodSugarSubType.values.firstWhere(
      (t) => t.name == metric.subType,
      orElse: () => BloodSugarSubType.fasting,
    );
    final status = HealthRanges.evaluateBloodSugar(metric.value, subType);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: _statusColor(status),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${metric.value.toInt()} mg/dL',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${subType.label} · ${DateFormat('MMM d, h:mm a').format(metric.recordedAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          RangeIndicator(status: status, compact: true),
        ],
      ),
    );
  }

  Color _statusColor(RangeStatus s) => switch (s) {
        RangeStatus.normal => AppColors.green,
        RangeStatus.borderline => AppColors.yellow,
        RangeStatus.high => AppColors.red,
        RangeStatus.low => const Color(0xFF1976D2),
      };
}
