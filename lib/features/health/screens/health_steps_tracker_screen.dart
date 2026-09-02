import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_theme.dart';
import '../data/health_database.dart';
import '../models/health_data.dart';
import '../providers/daily_log_provider.dart';
import '../providers/steps_provider.dart';
import '../widgets/health_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/steps_chart.dart';

class HealthStepsTrackerScreen extends ConsumerWidget {
  const HealthStepsTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(todayLogProvider);
    final weeklyLogs = ref.watch(weeklyStepsProvider);

    final steps = todayLog.valueOrNull?.steps ?? 0;
    const goalSteps = 10000;
    final progress = (steps / goalSteps).clamp(0.0, 1.0);

    final caloriesBurned = (steps * 0.04).toInt();
    final distanceKm = (steps * 0.0008).toStringAsFixed(1);
    final activeMin = (steps / 120).toInt();

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
          'Steps',
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
          HealthCard(
            child: Column(
              children: [
                ProgressRing(
                  progress: progress,
                  size: 160,
                  strokeWidth: 14,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatSteps(steps),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'of ${_formatSteps(goalSteps)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      icon: Icons.local_fire_department_rounded,
                      value: '$caloriesBurned',
                      label: 'kcal',
                      color: const Color(0xFFFF6B35),
                    ),
                    Container(
                      width: 1, height: 40,
                      color: AppColors.surfaceBorder,
                    ),
                    _StatItem(
                      icon: Icons.straighten_rounded,
                      value: distanceKm,
                      label: 'km',
                      color: AppColors.primary,
                    ),
                    Container(
                      width: 1, height: 40,
                      color: AppColors.surfaceBorder,
                    ),
                    _StatItem(
                      icon: Icons.timer_outlined,
                      value: '$activeMin',
                      label: 'min',
                      color: AppColors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'This week',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          HealthCard(
            child: weeklyLogs.when(
              data: (logs) {
                final chartData = _buildWeeklyData(logs);
                return StepsBarChart(data: chartData, goal: goalSteps);
              },
              loading: () => const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => const SizedBox(
                height: 140,
                child: Center(child: Text('Could not load data')),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          HealthCard(
            child: weeklyLogs.when(
              data: (logs) => _InsightsSection(logs: logs, goal: goalSteps),
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No data yet'),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  List<DailySteps> _buildWeeklyData(List<DailyLog> logs) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final fmt = DateFormat('yyyy-MM-dd');

    final logMap = {for (final l in logs) l.dateKey: l.steps};

    return List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      final key = fmt.format(date);
      return DailySteps(day: dayNames[i], steps: logMap[key] ?? 0);
    });
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(1)}k';
    return '$steps';
  }

}

class _InsightsSection extends StatelessWidget {
  final List<DailyLog> logs;
  final int goal;

  const _InsightsSection({required this.logs, required this.goal});

  @override
  Widget build(BuildContext context) {
    final stepsValues = logs.map((l) => l.steps).toList();
    final total = stepsValues.fold<int>(0, (s, v) => s + v);
    final avg = stepsValues.isEmpty ? 0 : total ~/ stepsValues.length;
    final best = stepsValues.isEmpty ? 0 : stepsValues.reduce((a, b) => a > b ? a : b);
    final daysReached = stepsValues.where((s) => s >= goal).length;

    return Column(
      children: [
        _InsightRow(
          icon: Icons.trending_up_rounded,
          color: AppColors.green,
          title: 'Average steps',
          value: '${_fmt(avg)} / day',
        ),
        const Divider(height: 24),
        _InsightRow(
          icon: Icons.emoji_events_rounded,
          color: AppColors.yellow,
          title: 'Best day',
          value: _fmt(best),
        ),
        const Divider(height: 24),
        _InsightRow(
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.primary,
          title: 'Goal reached',
          value: '$daysReached of ${stepsValues.length} days',
        ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _InsightRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
