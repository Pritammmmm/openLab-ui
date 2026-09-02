import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_theme.dart';
import '../data/health_database.dart';
import '../models/health_metric_type.dart';
import '../models/reference_ranges.dart';
import '../providers/blood_pressure_provider.dart';
import '../widgets/health_card.dart';
import '../widgets/metric_input_field.dart';
import '../widgets/range_indicator.dart';

class BloodPressureScreen extends ConsumerWidget {
  const BloodPressureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(bloodPressureListProvider);

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
          'Blood Pressure',
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
        backgroundColor: HealthMetricType.bloodPressure.color,
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
    final sysCtrl = TextEditingController();
    final diaCtrl = TextEditingController();
    final pulseCtrl = TextEditingController();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log Blood Pressure',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: MetricInputField(
                    controller: sysCtrl,
                    label: 'Systolic',
                    unit: 'mmHg',
                    hint: '120',
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricInputField(
                    controller: diaCtrl,
                    label: 'Diastolic',
                    unit: 'mmHg',
                    hint: '80',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MetricInputField(
              controller: pulseCtrl,
              label: 'Pulse (optional)',
              unit: 'bpm',
              hint: '72',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: HealthMetricType.bloodPressure.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  final sys = double.tryParse(sysCtrl.text);
                  final dia = double.tryParse(diaCtrl.text);
                  final pulse = double.tryParse(pulseCtrl.text);
                  if (sys != null && dia != null && sys > 0 && dia > 0) {
                    ref.read(bloodPressureActionsProvider).log(
                          systolic: sys,
                          diastolic: dia,
                          pulse: pulse,
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
            Icon(Icons.monitor_heart_rounded,
                size: 48, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text(
              'No readings yet',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap + to log your blood pressure',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final latest = metrics.first;
    final status = HealthRanges.evaluateBloodPressure(
      latest.value,
      latest.value2 ?? 80,
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        HealthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Latest Reading',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
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
                    '${latest.value.toInt()}',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6, left: 2, right: 2),
                    child: Text('/',
                        style: TextStyle(
                          fontSize: 28,
                          color: AppColors.textMuted,
                        )),
                  ),
                  Text(
                    '${latest.value2?.toInt() ?? '-'}',
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
                    child: Text('mmHg',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.textMuted)),
                  ),
                ],
              ),
              if (latest.value3 != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Pulse: ${latest.value3!.toInt()} bpm',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                DateFormat('MMM d, h:mm a').format(latest.recordedAt),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
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
              child: _BpTile(metric: m),
            )),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _BpTile extends StatelessWidget {
  final HealthMetric metric;

  const _BpTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    final status = HealthRanges.evaluateBloodPressure(
      metric.value,
      metric.value2 ?? 80,
    );
    final statusColor = switch (status) {
      RangeStatus.normal => AppColors.green,
      RangeStatus.borderline => AppColors.yellow,
      RangeStatus.high => AppColors.red,
      RangeStatus.low => const Color(0xFF1976D2),
    };

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
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${metric.value.toInt()}/${metric.value2?.toInt() ?? '-'} mmHg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM d, h:mm a').format(metric.recordedAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (metric.value3 != null)
            Text(
              '${metric.value3!.toInt()} bpm',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(width: 8),
          RangeIndicator(status: status, compact: true),
        ],
      ),
    );
  }
}
