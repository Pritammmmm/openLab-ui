import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../data/health_database.dart';
import '../models/health_metric_type.dart';
import '../models/reference_ranges.dart';
import '../providers/blood_sugar_provider.dart';
import '../providers/blood_pressure_provider.dart';
import '../providers/weight_provider.dart';
import '../providers/heart_rate_provider.dart';
import '../providers/daily_log_provider.dart';
import '../providers/food_log_provider.dart';
import '../providers/health_sync_provider.dart';
import '../providers/pedometer_provider.dart';
import '../providers/target_provider.dart';
import '../providers/stand_reminder_provider.dart';
import '../widgets/health_card.dart';

const _heroLight1 = Color(0xFFF8F5FF);
const _heroLight2 = Color(0xFFF2F0FF);
const _heroLight3 = Color(0xFFEEF3FF);
const _barGold = Color(0xFFFFB800);
const _barPurple = Color(0xFF7C5CBF);
const _barCyan = Color(0xFF4FC3F7);
const _barIndigo = Color(0xFF6E8EF7);

class HealthDashboardScreen extends ConsumerStatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  ConsumerState<HealthDashboardScreen> createState() =>
      _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends ConsumerState<HealthDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(healthSyncProvider.future);
      ref.read(healthSyncProvider.notifier).autoSyncIfEnabled();
      ref.read(pedometerToggleProvider.notifier).autoActivateIfNeeded();
      ref.read(dailyLogActionsProvider).syncCaloriesFromFood();
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayLog = ref.watch(todayLogProvider);
    final latestSugar = ref.watch(latestBloodSugarProvider);
    final latestBp = ref.watch(latestBloodPressureProvider);
    final latestWeight = ref.watch(latestWeightProvider);
    final latestHr = ref.watch(latestHeartRateProvider);
    final syncState = ref.watch(healthSyncProvider).valueOrNull;
    final effective = ref.watch(effectiveStepsProvider);
    final targets =
        ref.watch(healthTargetsProvider).valueOrNull ?? const HealthTargets();

    final glasses = todayLog.valueOrNull?.waterGlasses ?? 0;
    final calories = todayLog.valueOrNull?.caloriesConsumed ?? 0;
    final sleepMin = todayLog.valueOrNull?.sleepMinutes ?? 0;

    final stepGoal = targets.steps;
    final waterGoal = targets.water;
    final calGoal = targets.calories;
    final sleepGoal = targets.sleepMinutes;

    final stepsProgress = (effective.steps / stepGoal).clamp(0.0, 1.0);
    final waterProgress = (glasses / waterGoal).clamp(0.0, 1.0);
    final caloriesProgress = (calories / calGoal).clamp(0.0, 1.0);
    final sleepProgress = (sleepMin / sleepGoal).clamp(0.0, 1.0);

    final wellnessScore = ((stepsProgress * 30 +
                waterProgress * 20 +
                caloriesProgress * 25 +
                sleepProgress * 25) *
            100 /
            100)
        .round()
        .clamp(0, 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Health',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Today\'s overview',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/health/records'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.grid_view_rounded,
                            size: 20, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => context.push('/health/goals'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.flag_rounded,
                            size: 20, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SyncButton(syncState: syncState),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _HeroScoreCard(
                    wellnessScore: wellnessScore,
                    stepsProgress: stepsProgress,
                    waterProgress: waterProgress,
                    caloriesProgress: caloriesProgress,
                    sleepProgress: sleepProgress,
                    steps: effective.steps,
                    glasses: glasses,
                    calories: calories,
                    sleepMin: sleepMin,
                    stepGoal: stepGoal,
                    waterGoal: waterGoal,
                    calGoal: calGoal,
                    sleepGoal: sleepGoal,
                  ),
                  const SizedBox(height: 12),

                  // Steps + Water row
                  _ActivityRow(
                    steps: effective.steps,
                    stepGoal: stepGoal,
                    stepsProgress: stepsProgress,
                    glasses: glasses,
                    waterGoal: waterGoal,
                    waterProgress: waterProgress,
                    onAddWater: () =>
                        ref.read(dailyLogActionsProvider).addWater(),
                    onRemoveWater: glasses > 0
                        ? () =>
                            ref.read(dailyLogActionsProvider).removeWater()
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Meals & Calories
                  _MealCalorieCard(
                    calories: calories,
                    calGoal: calGoal,
                    caloriesProgress: caloriesProgress,
                  ),
                  const SizedBox(height: 12),

                  // Sleep card
                  _SleepCard(
                    sleepMin: sleepMin,
                    sleepGoal: sleepGoal,
                    sleepProgress: sleepProgress,
                    quality: todayLog.valueOrNull?.sleepQuality,
                    onLog: () => _showSleepLogger(context),
                  ),
                  const SizedBox(height: 12),

                  // Stand & Move
                  const _StandMoveCard(),
                  const SizedBox(height: 12),

                  _SyncBanner(syncState: syncState),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Text(
                        'Conditions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/health/vitals'),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ConditionCard(
                          icon: HealthMetricType.bloodSugar.icon,
                          color: HealthMetricType.bloodSugar.color,
                          title: 'Blood Sugar',
                          value: _formatSugar(latestSugar),
                          subtitle: _formatSugarSub(latestSugar),
                          status: _sugarStatus(latestSugar),
                          onTap: () => context.push('/health/blood-sugar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ConditionCard(
                          icon: HealthMetricType.bloodPressure.icon,
                          color: HealthMetricType.bloodPressure.color,
                          title: 'Blood Pressure',
                          value: _formatBp(latestBp),
                          subtitle: latestBp.valueOrNull != null
                              ? 'mmHg'
                              : 'No readings',
                          status: _bpStatus(latestBp),
                          onTap: () => context.push('/health/blood-pressure'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ConditionCard(
                          icon: HealthMetricType.weight.icon,
                          color: HealthMetricType.weight.color,
                          title: 'Weight',
                          value: _formatWeight(latestWeight),
                          subtitle: _formatWeightSub(latestWeight),
                          onTap: () => context.push('/health/weight'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ConditionCard(
                          icon: HealthMetricType.heartRate.icon,
                          color: HealthMetricType.heartRate.color,
                          title: 'Heart Rate',
                          value: _formatHr(latestHr),
                          subtitle: latestHr.valueOrNull != null
                              ? 'Resting'
                              : 'No readings',
                          status: _hrStatus(latestHr),
                          onTap: () => context.push('/health/vitals'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Quick Log',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickLogRow(),
                  const SizedBox(height: 24),
                  const MedicalDisclaimer(compact: true),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepLogger(BuildContext context) {
    var bedtime = TimeOfDay(hour: 22, minute: 30);
    var wakeUp = TimeOfDay(hour: 6, minute: 30);
    String quality = 'good';

    int calcMinutes(TimeOfDay bed, TimeOfDay wake) {
      final bedMin = bed.hour * 60 + bed.minute;
      final wakeMin = wake.hour * 60 + wake.minute;
      final diff = wakeMin <= bedMin
          ? (24 * 60 - bedMin) + wakeMin
          : wakeMin - bedMin;
      return diff;
    }

    String fmtTime(TimeOfDay t) {
      final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final m = t.minute.toString().padLeft(2, '0');
      final p = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '$h:$m $p';
    }

    ScaffoldWithNav.navBarVisible.value = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final totalMin = calcMinutes(bedtime, wakeUp);
          final h = totalMin ~/ 60;
          final m = totalMin % 60;

          Future<void> pickTime(bool isBedtime) async {
            final picked = await showTimePicker(
              context: ctx,
              initialTime: isBedtime ? bedtime : wakeUp,
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: Theme.of(c).colorScheme.copyWith(
                        primary: _barIndigo,
                      ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setSheetState(() {
                if (isBedtime) {
                  bedtime = picked;
                } else {
                  wakeUp = picked;
                }
              });
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Log Sleep',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickTime(true),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.nights_stay_rounded,
                                  size: 22,
                                  color: _barIndigo.withValues(alpha: 0.6)),
                              const SizedBox(height: 6),
                              const Text('Bedtime',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(fmtTime(bedtime),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 20,
                          color: AppColors.textMuted.withValues(alpha: 0.4)),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickTime(false),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.wb_sunny_rounded,
                                  size: 22,
                                  color: _barGold.withValues(alpha: 0.6)),
                              const SizedBox(height: 6),
                              const Text('Wake up',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(fmtTime(wakeUp),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _barIndigo.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 18, color: _barIndigo),
                      const SizedBox(width: 8),
                      Text(
                        '${h}h ${m > 0 ? '${m}m' : ''} of sleep',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _barIndigo,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quality',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ('poor', Icons.sentiment_very_dissatisfied_rounded,
                        AppColors.red),
                    ('fair', Icons.sentiment_neutral_rounded, AppColors.yellow),
                    ('good', Icons.sentiment_satisfied_rounded, _barIndigo),
                    ('great', Icons.sentiment_very_satisfied_rounded,
                        AppColors.green),
                  ].map((item) {
                    final sel = quality == item.$1;
                    return GestureDetector(
                      onTap: () => setSheetState(() => quality = item.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? item.$3.withValues(alpha: 0.12)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel ? item.$3 : AppColors.surfaceBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.$2,
                                size: 18,
                                color:
                                    sel ? item.$3 : AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              item.$1[0].toUpperCase() +
                                  item.$1.substring(1),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: sel ? item.$3 : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (totalMin > 0) {
                        ref
                            .read(dailyLogActionsProvider)
                            .updateSleep(totalMin, quality: quality);
                        Navigator.pop(ctx);
                      }
                    },
                    icon: const Icon(Icons.bedtime_rounded, size: 20),
                    label: const Text('Save Sleep',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    style: FilledButton.styleFrom(
                      backgroundColor: _barIndigo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() => ScaffoldWithNav.navBarVisible.value = true);
  }

  String _formatSugar(AsyncValue<HealthMetric?> a) {
    final m = a.valueOrNull;
    return m != null ? '${m.value.toInt()} mg/dL' : '—';
  }

  String _formatSugarSub(AsyncValue<HealthMetric?> a) {
    final m = a.valueOrNull;
    if (m == null) return 'No readings';
    return BloodSugarSubType.values
        .firstWhere((t) => t.name == m.subType,
            orElse: () => BloodSugarSubType.fasting)
        .label;
  }

  RangeStatus? _sugarStatus(AsyncValue<HealthMetric?> a) {
    final m = a.valueOrNull;
    if (m == null) return null;
    final sub = BloodSugarSubType.values
        .firstWhere((t) => t.name == m.subType,
            orElse: () => BloodSugarSubType.fasting);
    return HealthRanges.evaluateBloodSugar(m.value, sub);
  }

  String _formatBp(AsyncValue<HealthMetric?> a) {
    final m = a.valueOrNull;
    return m != null ? '${m.value.toInt()}/${m.value2?.toInt() ?? '-'}' : '—';
  }

  RangeStatus? _bpStatus(AsyncValue<HealthMetric?> a) {
    final m = a.valueOrNull;
    if (m == null) return null;
    return HealthRanges.evaluateBloodPressure(m.value, m.value2 ?? 80);
  }

  String _formatWeight(AsyncValue<HealthMetric?> a) {
    final m = a.valueOrNull;
    return m != null ? '${m.value.toStringAsFixed(1)} kg' : '—';
  }

  String _formatWeightSub(AsyncValue<HealthMetric?> a) {
    final m = a.valueOrNull;
    if (m == null) return 'No readings';
    if (m.value2 != null && m.value2! > 0) {
      return 'BMI ${WeightActions.computeBmi(m.value, m.value2!).toStringAsFixed(1)}';
    }
    return 'Logged';
  }

  String _formatHr(AsyncValue<HealthMetric?> a) {
    final m = a.valueOrNull;
    return m != null ? '${m.value.toInt()} bpm' : '—';
  }

  RangeStatus? _hrStatus(AsyncValue<HealthMetric?> a) {
    final m = a.valueOrNull;
    if (m == null) return null;
    return HealthRanges.evaluateHeartRate(m.value);
  }
}

// ─── Hero Score Card ────────────────────────────────────────────────────────

class _HeroScoreCard extends StatelessWidget {
  final int wellnessScore;
  final double stepsProgress, waterProgress, caloriesProgress, sleepProgress;
  final int steps, glasses, calories, sleepMin;
  final int stepGoal, waterGoal, calGoal, sleepGoal;

  const _HeroScoreCard({
    required this.wellnessScore,
    required this.stepsProgress,
    required this.waterProgress,
    required this.caloriesProgress,
    required this.sleepProgress,
    required this.steps,
    required this.glasses,
    required this.calories,
    required this.sleepMin,
    required this.stepGoal,
    required this.waterGoal,
    required this.calGoal,
    required this.sleepGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_heroLight1, _heroLight2, _heroLight3],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8E0F7).withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F33E1).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wellness Score',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActivityBar(
                      label: 'Steps',
                      progress: stepsProgress,
                      color: _barGold,
                      value: _formatNum(steps),
                      icon: Icons.directions_walk_rounded,
                    ),
                    _ActivityBar(
                      label: 'Water',
                      progress: waterProgress,
                      color: _barCyan,
                      value: '$glasses/$waterGoal',
                      icon: Icons.water_drop_rounded,
                    ),
                    _ActivityBar(
                      label: 'Cal',
                      progress: caloriesProgress,
                      color: _barPurple,
                      value: _formatNum(calories),
                      icon: Icons.local_fire_department_rounded,
                    ),
                    _ActivityBar(
                      label: 'Sleep',
                      progress: sleepProgress,
                      color: _barIndigo,
                      value: sleepMin > 0
                          ? '${sleepMin ~/ 60}h${sleepMin % 60 > 0 ? '${sleepMin % 60}m' : ''}'
                          : '—',
                      icon: Icons.bedtime_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AnimatedScoreRing(score: wellnessScore),
        ],
      ),
    );
  }

  static String _formatNum(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }
    return n.toString();
  }
}

class _AnimatedScoreRing extends StatefulWidget {
  final int score;
  const _AnimatedScoreRing({required this.score});

  @override
  State<_AnimatedScoreRing> createState() => _AnimatedScoreRingState();
}

class _AnimatedScoreRingState extends State<_AnimatedScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _anim = Tween<double>(begin: 0, end: widget.score / 100.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedScoreRing old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _anim = Tween<double>(begin: _anim.value, end: widget.score / 100.0)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final pct = (_anim.value * 100).round();
        return SizedBox(
          width: 96,
          height: 96,
          child: CustomPaint(
            painter: _ScoreRingPainter(progress: _anim.value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$pct%',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.0,
                        letterSpacing: -1,
                      )),
                  const Text('today',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  _ScoreRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFF5F33E1).withValues(alpha: 0.08)
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
    if (progress <= 0) return;

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + 2 * pi,
      colors: const [
        Color(0xFF5F33E1),
        Color(0xFF7B52F5),
        Color(0xFFFFB800),
        Color(0xFFFF6B35),
        Color(0xFF5F33E1),
      ],
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader =
            gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final endAngle = -pi / 2 + sweepAngle;
    final dotPos =
        Offset(center.dx + radius * cos(endAngle), center.dy + radius * sin(endAngle));
    canvas.drawCircle(
        dotPos,
        4,
        Paint()
          ..color = const Color(0xFFFFB800).withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawCircle(dotPos, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) => old.progress != progress;
}

// ─── Activity Bar ───────────────────────────────────────────────────────────

class _ActivityBar extends StatefulWidget {
  final String label;
  final double progress;
  final Color color;
  final String value;
  final IconData icon;
  const _ActivityBar(
      {required this.label,
      required this.progress,
      required this.color,
      required this.value,
      required this.icon});
  @override
  State<_ActivityBar> createState() => _ActivityBarState();
}

class _ActivityBarState extends State<_ActivityBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0, end: widget.progress)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_ActivityBar old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _anim = Tween<double>(begin: _anim.value, end: widget.progress)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, size: 13, color: widget.color),
        const SizedBox(height: 3),
        Text(widget.value,
            style: const TextStyle(
                fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _anim,
          builder: (context, _) => SizedBox(
            width: 22,
            height: 52,
            child: CustomPaint(
                painter: _BarPainter(
                    progress: _anim.value, color: widget.color)),
          ),
        ),
        const SizedBox(height: 4),
        Text(widget.label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            )),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  final double progress;
  final Color color;
  _BarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(8)),
      Paint()..color = Colors.black.withValues(alpha: 0.05),
    );
    if (progress <= 0) return;
    final fillH = size.height * progress.clamp(0.0, 1.0);
    final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height - fillH, size.width, fillH),
        const Radius.circular(8));
    canvas.drawRRect(
        fillRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [color, color.withValues(alpha: 0.7)],
          ).createShader(
              Rect.fromLTWH(0, size.height - fillH, size.width, fillH)));
    if (progress > 0.05) {
      canvas.drawCircle(Offset(size.width / 2, size.height - fillH + 4), 6,
          Paint()
            ..color = color.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Activity Row — Steps + Water ───────────────────────────────────────────

class _ActivityRow extends StatelessWidget {
  final int steps, stepGoal, glasses, waterGoal;
  final double stepsProgress, waterProgress;
  final VoidCallback onAddWater;
  final VoidCallback? onRemoveWater;

  const _ActivityRow({
    required this.steps,
    required this.stepGoal,
    required this.stepsProgress,
    required this.glasses,
    required this.waterGoal,
    required this.waterProgress,
    required this.onAddWater,
    required this.onRemoveWater,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactTrackerCard(
            icon: Icons.directions_walk_rounded,
            gradient: const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            title: 'Steps',
            value: _fmt(steps),
            subtitle: 'of ${_fmt(stepGoal)}',
            progress: stepsProgress,
            progressColor: const Color(0xFF4CAF50),
            onTap: () => context.push('/health/steps'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CompactWaterCard(
            glasses: glasses,
            goal: waterGoal,
            progress: waterProgress,
            onAdd: onAddWater,
            onRemove: onRemoveWater,
          ),
        ),
      ],
    );
  }

  static String _fmt(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }
    return n.toString();
  }
}

class _CompactTrackerCard extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final String title, value, subtitle;
  final double progress;
  final Color progressColor;
  final VoidCallback? onTap;

  const _CompactTrackerCard({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.progressColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted)),
            ]),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.0,
                  letterSpacing: -0.5,
                )),
            const SizedBox(height: 1),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            _MiniProgressBar(progress: progress, color: progressColor),
          ],
        ),
      ),
    );
  }
}

class _CompactWaterCard extends StatelessWidget {
  final int glasses, goal;
  final double progress;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  const _CompactWaterCard({
    required this.glasses,
    required this.goal,
    required this.progress,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/health/water'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF29B6F6), Color(0xFF4FC3F7)]),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.water_drop_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 6),
              const Text('Water',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted)),
              const Spacer(),
              _MiniCircleBtn(icon: Icons.remove_rounded, onTap: onRemove),
              const SizedBox(width: 3),
              _MiniCircleBtn(icon: Icons.add_rounded, onTap: onAdd),
            ]),
            const SizedBox(height: 8),
            Text('$glasses',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.0,
                  letterSpacing: -0.5,
                )),
            const SizedBox(height: 1),
            Text('of $goal glasses',
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            _MiniProgressBar(
                progress: progress, color: const Color(0xFF29B6F6)),
          ],
        ),
      ),
    );
  }
}

class _MiniCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _MiniCircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF29B6F6).withValues(alpha: 0.1)
              : AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 12,
            color: enabled ? const Color(0xFF0288D1) : AppColors.textMuted),
      ),
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  const _MiniProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(children: [
          Container(color: color.withValues(alpha: 0.1)),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Meal & Calorie Card ────────────────────────────────────────────────────

class _MealCalorieCard extends ConsumerWidget {
  final int calories, calGoal;
  final double caloriesProgress;

  const _MealCalorieCard({
    required this.calories,
    required this.calGoal,
    required this.caloriesProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foodEntriesAsync = ref.watch(todayFoodEntriesProvider);
    final mealCount = foodEntriesAsync.valueOrNull?.length ?? 0;
    final remaining = (calGoal - calories).clamp(0, calGoal);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFFAC0C)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_fire_department_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('Meals & Calories',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/health/food'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text('Log',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _CalStat(
                    label: 'Consumed',
                    value: '$calories',
                    unit: 'kcal',
                    color: const Color(0xFFFF6B35))),
            Container(width: 1, height: 32, color: AppColors.divider),
            Expanded(
                child: _CalStat(
                    label: 'Remaining',
                    value: '$remaining',
                    unit: 'kcal',
                    color: AppColors.green)),
            Container(width: 1, height: 32, color: AppColors.divider),
            Expanded(
                child: _CalStat(
                    label: 'Meals',
                    value: '$mealCount',
                    unit: 'today',
                    color: AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          _MiniProgressBar(
            progress: caloriesProgress,
            color:
                caloriesProgress > 0.9 ? AppColors.red : const Color(0xFFFF6B35),
          ),
          if (foodEntriesAsync.valueOrNull != null &&
              foodEntriesAsync.valueOrNull!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...foodEntriesAsync.valueOrNull!.take(3).map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Icon(
                        MealType.values
                            .firstWhere((t) => t.name == e.mealType,
                                orElse: () => MealType.breakfast)
                            .icon,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(e.name,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('${e.calories} kcal',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted)),
                    ]),
                  ),
                ),
            if (foodEntriesAsync.valueOrNull!.length > 3)
              GestureDetector(
                onTap: () => context.push('/health/food'),
                child: const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text('View all meals →',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _CalStat extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _CalStat(
      {required this.label,
      required this.value,
      required this.unit,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0)),
      const SizedBox(height: 2),
      Text(unit,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary)),
    ]);
  }
}

// ─── Sleep Card ─────────────────────────────────────────────────────────────

class _SleepCard extends StatelessWidget {
  final int sleepMin, sleepGoal;
  final double sleepProgress;
  final String? quality;
  final VoidCallback onLog;

  const _SleepCard({
    required this.sleepMin,
    required this.sleepGoal,
    required this.sleepProgress,
    required this.quality,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final h = sleepMin ~/ 60;
    final m = sleepMin % 60;
    final goalH = sleepGoal ~/ 60;
    final goalM = sleepGoal % 60;
    final hasData = sleepMin > 0;
    final deficit = sleepGoal - sleepMin;

    final qualityLabel = switch (quality) {
      'poor' => 'Poor',
      'fair' => 'Fair',
      'good' => 'Good',
      'great' => 'Great',
      _ => null,
    };
    final qualityColor = switch (quality) {
      'poor' => AppColors.red,
      'fair' => AppColors.yellow,
      'good' => _barIndigo,
      'great' => AppColors.green,
      _ => AppColors.textMuted,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F2FF), Color(0xFFEEF0FF), Color(0xFFEBF0FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _barIndigo.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
              color: _barIndigo.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF5C6BC0), Color(0xFF6E8EF7)]),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.bedtime_rounded,
                  color: Colors.white, size: 15),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sleep',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text('Tonight\'s rest',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted)),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: onLog,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _barIndigo.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(hasData ? Icons.edit_rounded : Icons.add_rounded,
                        size: 14, color: _barIndigo),
                    const SizedBox(width: 4),
                    Text(hasData ? 'Edit' : 'Log Sleep',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _barIndigo)),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          if (hasData) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${h}h ${m > 0 ? '${m}m' : ''}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'of ${goalH}h${goalM > 0 ? ' ${goalM}m' : ''} goal',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (deficit > 0)
                        Text(
                          '${deficit ~/ 60 > 0 ? '${deficit ~/ 60}h ' : ''}${deficit % 60 > 0 ? '${deficit % 60}m ' : ''}under target',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.yellow.withValues(alpha: 0.9),
                          ),
                        )
                      else
                        const Text(
                          'Goal reached!',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),
                    ],
                  ),
                ),
                if (qualityLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: qualityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: qualityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          qualityLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: qualityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _barIndigo.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: sleepProgress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5C6BC0), _barIndigo],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            GestureDetector(
              onTap: onLog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _barIndigo.withValues(alpha: 0.1),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.nightlight_round,
                        size: 28,
                        color: _barIndigo.withValues(alpha: 0.3)),
                    const SizedBox(height: 6),
                    const Text('Tap to log tonight\'s sleep',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    Text(
                      'Target: ${goalH}h${goalM > 0 ? ' ${goalM}m' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _barIndigo.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stand & Move Card ─────────────────────────────────────────────────────

class _StandMoveCard extends ConsumerWidget {
  const _StandMoveCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(standReminderProvider);
    final active = state.isActive;

    return GestureDetector(
      onTap: () => context.push('/health/stand-reminder'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: active
                ? [const Color(0xFFFFF8F0), const Color(0xFFFFF3E6)]
                : [AppColors.surface, AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(18),
          border: active
              ? Border.all(
                  color: const Color(0xFFFF9500).withValues(alpha: 0.12))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFF9500), Color(0xFFFF6B35)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_walk_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stand & Move',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text(
                    active
                        ? 'Active · Every ${state.intervalMinutes}min'
                        : 'Tap to set up break reminders',
                    style: TextStyle(
                      fontSize: 11,
                      color: active
                          ? const Color(0xFFFF9500)
                          : AppColors.textMuted,
                      fontWeight:
                          active ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9500).withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.textMuted.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Condition Card ─────────────────────────────────────────────────────────

class _ConditionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, value, subtitle;
  final RangeStatus? status;
  final VoidCallback? onTap;

  const _ConditionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (status) {
      RangeStatus.normal => AppColors.green,
      RangeStatus.borderline => AppColors.yellow,
      RangeStatus.high => AppColors.red,
      RangeStatus.low => const Color(0xFF4FC3F7),
      null => null,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: statusColor != null
              ? Border.all(color: statusColor.withValues(alpha: 0.15), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 14),
              ),
              const Spacer(),
              if (statusColor != null)
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 3),
                    ],
                  ),
                ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.textMuted),
            ]),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.1)),
            const SizedBox(height: 1),
            Text(subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor ?? AppColors.textMuted,
                  fontWeight:
                      statusColor != null ? FontWeight.w500 : FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Log Row ──────────────────────────────────────────────────────────

class _QuickLogRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _QuickLogChip(
            icon: Icons.bloodtype_rounded,
            label: 'Blood Sugar',
            color: HealthMetricType.bloodSugar.color,
            onTap: () => context.push('/health/blood-sugar')),
        const SizedBox(width: 10),
        _QuickLogChip(
            icon: Icons.monitor_heart_rounded,
            label: 'Blood Pressure',
            color: HealthMetricType.bloodPressure.color,
            onTap: () => context.push('/health/blood-pressure')),
        const SizedBox(width: 10),
        _QuickLogChip(
            icon: Icons.monitor_weight_rounded,
            label: 'Weight',
            color: HealthMetricType.weight.color,
            onTap: () => context.push('/health/weight')),
        const SizedBox(width: 10),
        _QuickLogChip(
            icon: Icons.water_drop_rounded,
            label: 'Water',
            color: const Color(0xFF4FC3F7),
            onTap: () => context.push('/health/water')),
        const SizedBox(width: 10),
        _QuickLogChip(
            icon: Icons.restaurant_rounded,
            label: 'Food',
            color: AppColors.green,
            onTap: () => context.push('/health/food')),
        const SizedBox(width: 10),
        _QuickLogChip(
            icon: Icons.bedtime_rounded,
            label: 'Sleep',
            color: _barIndigo,
            onTap: () => context.push('/health/goals')),
      ]),
    );
  }
}

class _QuickLogChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickLogChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration:
                  BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─── Sync Button + Banner ───────────────────────────────────────────────────

class _SyncButton extends StatelessWidget {
  final HealthSyncState? syncState;
  const _SyncButton({required this.syncState});

  @override
  Widget build(BuildContext context) {
    final connected = syncState?.anyEnabled ?? false;
    final syncing = syncState?.isSyncing ?? false;
    return GestureDetector(
      onTap: () => context.push('/health/sync-settings'),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (syncing)
              const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary))
            else
              Icon(Icons.sync_rounded,
                  size: 22,
                  color: connected ? AppColors.primary : AppColors.textMuted),
            if (connected && !syncing)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SyncBanner extends ConsumerWidget {
  final HealthSyncState? syncState;
  const _SyncBanner({required this.syncState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (syncState == null) return const SizedBox.shrink();
    final state = syncState!;

    if (!state.anyEnabled) return _buildSetupBanner(context);
    if (state.isSyncing) return _buildSyncingBanner();
    if (state.syncStatus == SyncStatus.success && state.lastSyncCount > 0) {
      return _buildSuccessBanner(state);
    }
    if (state.syncStatus == SyncStatus.failed) {
      return _buildErrorBanner(context, ref, state);
    }
    return _buildIdleBanner(context, ref, state);
  }

  Widget _buildSetupBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/health/sync-settings'),
      child: HealthCard(
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.sync_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sync your health data',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                SizedBox(height: 2),
                Text('Connect Samsung Health or Google Fit',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 20),
        ]),
      ),
    );
  }

  Widget _buildSyncingBanner() {
    return HealthCard(
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12)),
          child: const Center(
            child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary)),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Syncing health data...',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              SizedBox(height: 2),
              Text('Reading from Health Connect',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildSuccessBanner(HealthSyncState state) {
    final types = state.lastSyncPerType;
    final summary = types.entries.map((e) => '${e.value} ${e.key}').join(' · ');
    return HealthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.green, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${state.lastSyncCount} data points synced',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  if (state.lastSyncAt != null) ...[
                    const SizedBox(height: 2),
                    Text(_relativeTime(state.lastSyncAt!),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ],
              ),
            ),
          ]),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.greenBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(summary,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.green)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBanner(
      BuildContext context, WidgetRef ref, HealthSyncState state) {
    return HealthCard(
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.sync_problem_rounded,
              color: AppColors.red, size: 18),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sync failed',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              SizedBox(height: 2),
              Text('Tap to retry',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => ref.read(healthSyncProvider.notifier).syncNow(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('Retry',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        ),
      ]),
    );
  }

  Widget _buildIdleBanner(
      BuildContext context, WidgetRef ref, HealthSyncState state) {
    final hasLastSync = state.lastSyncAt != null;
    final noNewData =
        state.syncStatus == SyncStatus.success && state.lastSyncCount == 0;
    return HealthCard(
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.greenBg,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.sync_rounded,
              color: AppColors.green, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  noNewData
                      ? 'All data up to date'
                      : hasLastSync
                          ? 'Synced ${_relativeTime(state.lastSyncAt!)}'
                          : 'Health Connect linked',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(
                  noNewData
                      ? 'No new data found in Health Connect'
                      : hasLastSync
                          ? 'Fetched ${state.lastFetchedCount} points from Health Connect'
                          : 'Tap Sync Now to pull your data',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => ref.read(healthSyncProvider.notifier).syncNow(),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('Sync',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ),
        ),
      ]),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }
}
