import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_theme.dart';
import '../data/health_database.dart';
import '../providers/health_providers.dart';
import '../providers/daily_log_provider.dart';
import '../providers/pedometer_provider.dart';
import '../providers/food_log_provider.dart';
import '../providers/target_provider.dart';

// ─── Category model ────────────────────────────────────────────────────────

class _RecordCategory {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final List<_RecordItem> items;

  const _RecordCategory({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.items,
  });
}

class _RecordItem {
  final String key;
  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final String route;

  const _RecordItem({
    required this.key,
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
    required this.route,
  });
}

final _categories = [
  _RecordCategory(
    title: 'Activity',
    icon: Icons.directions_run_rounded,
    gradient: const [Color(0xFFFF9500), Color(0xFFFF6B35)],
    items: const [
      _RecordItem(
        key: 'steps',
        label: 'Steps',
        unit: 'steps',
        icon: Icons.directions_walk_rounded,
        color: Color(0xFF34C759),
        route: '/health/steps',
      ),
      _RecordItem(
        key: 'calories',
        label: 'Calories',
        unit: 'kcal',
        icon: Icons.local_fire_department_rounded,
        color: Color(0xFFFF6B35),
        route: '/health/food',
      ),
      _RecordItem(
        key: 'water',
        label: 'Water',
        unit: 'glasses',
        icon: Icons.water_drop_rounded,
        color: Color(0xFF4FC3F7),
        route: '/health/water',
      ),
    ],
  ),
  _RecordCategory(
    title: 'Vitals',
    icon: Icons.favorite_rounded,
    gradient: const [Color(0xFFFF2D55), Color(0xFFFF6B81)],
    items: const [
      _RecordItem(
        key: 'heart_rate',
        label: 'Heart Rate',
        unit: 'bpm',
        icon: Icons.monitor_heart_rounded,
        color: Color(0xFFFF2D55),
        route: '/health/vitals',
      ),
      _RecordItem(
        key: 'blood_pressure',
        label: 'Blood Pressure',
        unit: 'mmHg',
        icon: Icons.speed_rounded,
        color: Color(0xFF5856D6),
        route: '/health/blood-pressure',
      ),
      _RecordItem(
        key: 'blood_sugar',
        label: 'Blood Sugar',
        unit: 'mg/dL',
        icon: Icons.bloodtype_rounded,
        color: Color(0xFFFF9500),
        route: '/health/blood-sugar',
      ),
    ],
  ),
  _RecordCategory(
    title: 'Body',
    icon: Icons.accessibility_new_rounded,
    gradient: const [Color(0xFF5856D6), Color(0xFF7B52F5)],
    items: const [
      _RecordItem(
        key: 'weight',
        label: 'Weight',
        unit: 'kg',
        icon: Icons.monitor_weight_rounded,
        color: Color(0xFF5F33E1),
        route: '/health/weight',
      ),
    ],
  ),
  _RecordCategory(
    title: 'Sleep',
    icon: Icons.bedtime_rounded,
    gradient: const [Color(0xFF5C6BC0), Color(0xFF6E8EF7)],
    items: const [
      _RecordItem(
        key: 'sleep',
        label: 'Sleep',
        unit: 'hrs',
        icon: Icons.bedtime_rounded,
        color: Color(0xFF6E8EF7),
        route: '',
      ),
    ],
  ),
  _RecordCategory(
    title: 'Nutrition',
    icon: Icons.restaurant_rounded,
    gradient: const [Color(0xFF34C759), Color(0xFF30D158)],
    items: const [
      _RecordItem(
        key: 'food',
        label: 'Food Log',
        unit: 'meals',
        icon: Icons.restaurant_menu_rounded,
        color: Color(0xFF34C759),
        route: '/health/food',
      ),
    ],
  ),
  _RecordCategory(
    title: 'Ergonomics',
    icon: Icons.airline_seat_recline_normal_rounded,
    gradient: const [Color(0xFFFF9500), Color(0xFFFF6B35)],
    items: const [
      _RecordItem(
        key: 'stand',
        label: 'Stand & Move',
        unit: '',
        icon: Icons.directions_walk_rounded,
        color: Color(0xFFFF9500),
        route: '/health/stand-reminder',
      ),
    ],
  ),
  _RecordCategory(
    title: 'Medications',
    icon: Icons.medication_rounded,
    gradient: const [Color(0xFF5856D6), Color(0xFF7B52F5)],
    items: const [
      _RecordItem(
        key: 'medicine',
        label: 'Medications',
        unit: '',
        icon: Icons.medication_rounded,
        color: Color(0xFF5856D6),
        route: '/medicine',
      ),
    ],
  ),
];

// ─── Providers for records data ────────────────────────────────────────────

final _weeklyLogsProvider =
    FutureProvider.autoDispose<List<DailyLog>>((ref) async {
  final db = ref.watch(healthDatabaseProvider);
  final fmt = DateFormat('yyyy-MM-dd');
  final today = DateTime.now();
  final weekAgo = today.subtract(const Duration(days: 6));
  return db.getDailyLogRange(fmt.format(weekAgo), fmt.format(today));
});

final _recentMetricsProvider = FutureProvider.autoDispose
    .family<List<HealthMetric>, String>((ref, type) async {
  final db = ref.watch(healthDatabaseProvider);
  final weekAgo = DateTime.now().subtract(const Duration(days: 7));
  return db.getMetricsByType(type, from: weekAgo, limit: 7);
});

// ─── Screen ────────────────────────────────────────────────────────────────

class HealthRecordsScreen extends ConsumerStatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  ConsumerState<HealthRecordsScreen> createState() =>
      _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends ConsumerState<HealthRecordsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayLog = ref.watch(todayLogProvider);
    final weeklyLogs = ref.watch(_weeklyLogsProvider);
    final targets =
        ref.watch(healthTargetsProvider).valueOrNull ?? const HealthTargets();
    final effective = ref.watch(effectiveStepsProvider);
    final foodEntries = ref.watch(todayFoodEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            expandedHeight: 120,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 16, right: 16),
              title: const Text(
                'Health Records',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0.95),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Highlights row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: _HighlightsRow(
                steps: effective.steps,
                water: todayLog.valueOrNull?.waterGlasses ?? 0,
                calories: todayLog.valueOrNull?.caloriesConsumed ?? 0,
                sleepMin: todayLog.valueOrNull?.sleepMinutes ?? 0,
                stepGoal: targets.steps,
                waterGoal: targets.water,
                calGoal: targets.calories,
                sleepGoal: targets.sleepMinutes,
              ),
            ),
          ),

          // Categories
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = _categories[index];

                  final delay = (index / _categories.length).clamp(0.0, 1.0);
                  final itemAnim = CurvedAnimation(
                    parent: _staggerCtrl,
                    curve: Interval(
                        delay, (delay + 0.4).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic),
                  );

                  return AnimatedBuilder(
                    animation: itemAnim,
                    builder: (context, child) => Opacity(
                      opacity: itemAnim.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - itemAnim.value)),
                        child: child,
                      ),
                    ),
                    child: _CategorySection(
                      category: cat,
                      weeklyLogs: weeklyLogs.valueOrNull ?? [],
                      todayLog: todayLog.valueOrNull,
                      steps: effective.steps,
                      foodCount:
                          foodEntries.valueOrNull?.length ?? 0,
                      recentMetrics: (type) =>
                          ref.watch(_recentMetricsProvider(type)),
                    ),
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Highlights Row ────────────────────────────────────────────────────────

class _HighlightsRow extends StatelessWidget {
  final int steps, water, calories, sleepMin;
  final int stepGoal, waterGoal, calGoal, sleepGoal;

  const _HighlightsRow({
    required this.steps,
    required this.water,
    required this.calories,
    required this.sleepMin,
    required this.stepGoal,
    required this.waterGoal,
    required this.calGoal,
    required this.sleepGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HighlightChip(
          icon: Icons.directions_walk_rounded,
          value: _fmtK(steps),
          label: 'Steps',
          progress: (steps / stepGoal).clamp(0.0, 1.0),
          color: const Color(0xFF34C759),
        ),
        const SizedBox(width: 8),
        _HighlightChip(
          icon: Icons.water_drop_rounded,
          value: '$water',
          label: 'Water',
          progress: (water / waterGoal).clamp(0.0, 1.0),
          color: const Color(0xFF4FC3F7),
        ),
        const SizedBox(width: 8),
        _HighlightChip(
          icon: Icons.local_fire_department_rounded,
          value: _fmtK(calories),
          label: 'Cal',
          progress: (calories / calGoal).clamp(0.0, 1.0),
          color: const Color(0xFFFF6B35),
        ),
        const SizedBox(width: 8),
        _HighlightChip(
          icon: Icons.bedtime_rounded,
          value: sleepMin > 0 ? '${sleepMin ~/ 60}h' : '—',
          label: 'Sleep',
          progress: (sleepMin / sleepGoal).clamp(0.0, 1.0),
          color: const Color(0xFF6E8EF7),
        ),
      ],
    );
  }

  static String _fmtK(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _HighlightChip extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final double progress;
  final Color color;

  const _HighlightChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.0)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Section ──────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  final _RecordCategory category;
  final List<DailyLog> weeklyLogs;
  final DailyLog? todayLog;
  final int steps;
  final int foodCount;
  final AsyncValue<List<HealthMetric>> Function(String type) recentMetrics;

  const _CategorySection({
    required this.category,
    required this.weeklyLogs,
    required this.todayLog,
    required this.steps,
    required this.foodCount,
    required this.recentMetrics,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: category.gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < category.items.length; i++) ...[
                  _RecordRow(
                    item: category.items[i],
                    displayValue: _getValue(category.items[i].key),
                    sparkData: _getSparkData(category.items[i].key),
                    onTap: category.items[i].route.isNotEmpty
                        ? () {
                            HapticFeedback.selectionClick();
                            context.push(category.items[i].route);
                          }
                        : null,
                  ),
                  if (i < category.items.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 56),
                      child: Container(height: 0.5, color: AppColors.divider),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getValue(String key) {
    switch (key) {
      case 'steps':
        return _fmtNum(steps);
      case 'calories':
        return _fmtNum(todayLog?.caloriesConsumed ?? 0);
      case 'water':
        return '${todayLog?.waterGlasses ?? 0}';
      case 'sleep':
        final min = todayLog?.sleepMinutes ?? 0;
        if (min == 0) return '—';
        return '${min ~/ 60}h ${min % 60 > 0 ? '${min % 60}m' : ''}';
      case 'heart_rate':
        final metrics = recentMetrics('heart_rate');
        final latest = metrics.valueOrNull?.firstOrNull;
        return latest != null ? '${latest.value.toInt()}' : '—';
      case 'blood_pressure':
        final metrics = recentMetrics('blood_pressure');
        final latest = metrics.valueOrNull?.firstOrNull;
        return latest != null
            ? '${latest.value.toInt()}/${latest.value2?.toInt() ?? '—'}'
            : '—';
      case 'blood_sugar':
        final metrics = recentMetrics('blood_sugar');
        final latest = metrics.valueOrNull?.firstOrNull;
        return latest != null ? '${latest.value.toInt()}' : '—';
      case 'weight':
        final metrics = recentMetrics('weight');
        final latest = metrics.valueOrNull?.firstOrNull;
        return latest != null ? latest.value.toStringAsFixed(1) : '—';
      case 'food':
        return '$foodCount';
      case 'medicine':
        return '';
      default:
        return '—';
    }
  }

  List<double> _getSparkData(String key) {
    if (weeklyLogs.isEmpty) return [];
    switch (key) {
      case 'steps':
        return weeklyLogs.map((l) => l.steps.toDouble()).toList();
      case 'calories':
        return weeklyLogs.map((l) => l.caloriesConsumed.toDouble()).toList();
      case 'water':
        return weeklyLogs.map((l) => l.waterGlasses.toDouble()).toList();
      case 'sleep':
        return weeklyLogs.map((l) => l.sleepMinutes.toDouble()).toList();
      case 'heart_rate':
      case 'blood_pressure':
      case 'blood_sugar':
      case 'weight':
        final metrics = recentMetrics(key);
        return metrics.valueOrNull?.reversed
                .map((m) => m.value)
                .toList() ??
            [];
      default:
        return [];
    }
  }

  static String _fmtNum(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}k';
    if (n >= 1000) {
      final s = n.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return '$n';
  }
}

// ─── Record Row ────────────────────────────────────────────────────────────

class _RecordRow extends StatelessWidget {
  final _RecordItem item;
  final String displayValue;
  final List<double> sparkData;
  final VoidCallback? onTap;

  const _RecordRow({
    required this.item,
    required this.displayValue,
    required this.sparkData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (displayValue.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            displayValue,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: item.color,
                            ),
                          ),
                          if (item.unit.isNotEmpty)
                            Text(
                              ' ${item.unit}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Mini sparkline
              if (sparkData.length >= 2)
                SizedBox(
                  width: 56,
                  height: 28,
                  child: CustomPaint(
                    painter: _SparklinePainter(
                      data: sparkData,
                      color: item.color,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textMuted.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sparkline painter ─────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(min);
    final maxVal = data.reduce(max);
    final range = maxVal - minVal;

    double normalize(double v) {
      if (range == 0) return 0.5;
      return (v - minVal) / range;
    }

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - normalize(data[i]) * size.height;
      points.add(Offset(x, y));
    }

    // Fill
    final fillPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpX = (prev.dx + curr.dx) / 2;
      fillPath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // End dot
    canvas.drawCircle(
      points.last,
      2.5,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color;
}
