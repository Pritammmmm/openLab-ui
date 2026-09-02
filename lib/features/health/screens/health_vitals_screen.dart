import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../data/health_database.dart';
import '../models/health_metric_type.dart';
import '../models/reference_ranges.dart';
import '../providers/health_providers.dart';
import '../widgets/health_card.dart';
import '../widgets/range_indicator.dart';
import '../widgets/metric_input_field.dart';

final _heartRateListProvider =
    StreamProvider.autoDispose<List<HealthMetric>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchMetricsByType('heartRate', limit: 30);
});

final _spo2ListProvider =
    StreamProvider.autoDispose<List<HealthMetric>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchMetricsByType('spo2', limit: 30);
});

final _temperatureListProvider =
    StreamProvider.autoDispose<List<HealthMetric>>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  return db.watchMetricsByType('temperature', limit: 30);
});

class HealthVitalsScreen extends ConsumerWidget {
  const HealthVitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heartRates = ref.watch(_heartRateListProvider);
    final spo2List = ref.watch(_spo2ListProvider);
    final tempList = ref.watch(_temperatureListProvider);

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
          'Vitals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _VitalSection(
            type: HealthMetricType.heartRate,
            metrics: heartRates,
            formatValue: (m) => '${m.value.toInt()} bpm',
            evaluateStatus: (m) =>
                HealthRanges.heartRate.evaluate(m.value),
            onLog: () => _showLogSheet(
              context, ref,
              type: 'heartRate',
              title: 'Heart Rate',
              unit: 'bpm',
              fields: const [_Field(label: 'BPM', hint: '72')],
            ),
          ),
          const SizedBox(height: 20),
          _VitalSection(
            type: HealthMetricType.spo2,
            metrics: spo2List,
            formatValue: (m) => '${m.value.toInt()}%',
            evaluateStatus: (m) =>
                HealthRanges.spo2.evaluate(m.value),
            onLog: () => _showLogSheet(
              context, ref,
              type: 'spo2',
              title: 'SpO2',
              unit: '%',
              fields: const [_Field(label: 'SpO2', hint: '98')],
            ),
          ),
          const SizedBox(height: 20),
          _VitalSection(
            type: HealthMetricType.temperature,
            metrics: tempList,
            formatValue: (m) => '${m.value.toStringAsFixed(1)} °F',
            evaluateStatus: (m) {
              if (m.value < 97.0) return RangeStatus.low;
              if (m.value <= 99.0) return RangeStatus.normal;
              if (m.value <= 100.4) return RangeStatus.borderline;
              return RangeStatus.high;
            },
            onLog: () => _showLogSheet(
              context, ref,
              type: 'temperature',
              title: 'Temperature',
              unit: '°F',
              fields: const [_Field(label: 'Temp', hint: '98.6')],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showLogSheet(
    BuildContext context,
    WidgetRef ref, {
    required String type,
    required String title,
    required String unit,
    required List<_Field> fields,
  }) {
    final controllers =
        fields.map((_) => TextEditingController()).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Log $title',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ...List.generate(fields.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MetricInputField(
                  label: fields[i].label,
                  unit: unit,
                  controller: controllers[i],
                  hint: fields[i].hint,
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  final val =
                      double.tryParse(controllers[0].text.trim());
                  if (val == null || val <= 0) return;
                  final db = ref.read(healthDatabaseProvider);
                  db.insertMetric(HealthMetricsCompanion.insert(
                    type: type,
                    value: val,
                    unit: unit,
                    recordedAt: DateTime.now(),
                    createdAt: DateTime.now(),
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field {
  final String label;
  final String hint;
  const _Field({required this.label, required this.hint});
}

class _VitalSection extends StatelessWidget {
  final HealthMetricType type;
  final AsyncValue<List<HealthMetric>> metrics;
  final String Function(HealthMetric) formatValue;
  final RangeStatus Function(HealthMetric) evaluateStatus;
  final VoidCallback onLog;

  const _VitalSection({
    required this.type,
    required this.metrics,
    required this.formatValue,
    required this.evaluateStatus,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: type.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(type.icon, color: type.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type.label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onLog,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+ Log',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: type.color,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        metrics.when(
          data: (list) {
            if (list.isEmpty) {
              return HealthCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No ${type.label.toLowerCase()} readings yet',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }

            final latest = list.first;
            return Column(
              children: [
                HealthCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatValue(latest),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _timeAgo(latest.recordedAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RangeIndicator(status: evaluateStatus(latest)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...list.skip(1).take(5).map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: HealthCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                formatValue(m),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            RangeIndicator(
                              status: evaluateStatus(m),
                              compact: true,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatDate(m.recordedAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            );
          },
          loading: () => const HealthCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
          error: (_, _) => const HealthCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Could not load data'),
            ),
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month]} ${dt.day}';
  }
}
