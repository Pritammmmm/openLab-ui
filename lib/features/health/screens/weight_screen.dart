import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_theme.dart';
import '../data/health_database.dart';
import '../models/health_metric_type.dart';
import '../providers/weight_provider.dart';
import '../widgets/health_card.dart';
import '../widgets/metric_input_field.dart';

class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(weightListProvider);

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
          'Weight & BMI',
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
        backgroundColor: HealthMetricType.weight.color,
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
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();

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
              'Log Weight',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            MetricInputField(
              controller: weightCtrl,
              label: 'Weight',
              unit: 'kg',
              autofocus: true,
            ),
            const SizedBox(height: 12),
            MetricInputField(
              controller: heightCtrl,
              label: 'Height (optional)',
              unit: 'cm',
              hint: '170',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: HealthMetricType.weight.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  final w = double.tryParse(weightCtrl.text);
                  final h = double.tryParse(heightCtrl.text);
                  if (w != null && w > 0) {
                    ref.read(weightActionsProvider).log(
                          weight: w,
                          heightCm: h,
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
            Icon(Icons.monitor_weight_rounded,
                size: 48, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text(
              'No entries yet',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap + to log your weight',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    final latest = metrics.first;
    final heightCm = latest.value2;
    final bmi = heightCm != null && heightCm > 0
        ? WeightActions.computeBmi(latest.value, heightCm)
        : null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        HealthCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Weight',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          latest.value.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 4),
                          child: Text('kg',
                              style: TextStyle(
                                  fontSize: 16, color: AppColors.textMuted)),
                        ),
                      ],
                    ),
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
              if (bmi != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _bmiColor(bmi).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _bmiColor(bmi),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'BMI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _bmiColor(bmi),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        WeightActions.bmiCategory(bmi),
                        style: TextStyle(
                          fontSize: 10,
                          color: _bmiColor(bmi),
                        ),
                      ),
                    ],
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
              child: _WeightTile(metric: m),
            )),
        const SizedBox(height: 100),
      ],
    );
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF1976D2);
    if (bmi < 25) return AppColors.green;
    if (bmi < 30) return AppColors.yellow;
    return AppColors.red;
  }
}

class _WeightTile extends StatelessWidget {
  final HealthMetric metric;

  const _WeightTile({required this.metric});

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.primary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${metric.value.toStringAsFixed(1)} kg',
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
          if (metric.value2 != null && metric.value2! > 0) ...[
            Text(
              'BMI ${WeightActions.computeBmi(metric.value, metric.value2!).toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
