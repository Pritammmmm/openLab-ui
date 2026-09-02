import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../data/health_database.dart';
import '../providers/goals_provider.dart';
import '../providers/daily_log_provider.dart';
import '../providers/weight_provider.dart';
import '../widgets/progress_ring.dart';

class HealthGoalsScreen extends ConsumerWidget {
  const HealthGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsListProvider);
    final todayLog = ref.watch(todayLogProvider);
    final latestWeight = ref.watch(latestWeightProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => _showGoalEditor(context, ref, null),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_rounded,
                      size: 22, color: AppColors.primary),
                ),
              ),
            ],
          ),
          goalsAsync.when(
            data: (goals) {
              if (goals.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    onAdd: () => _showGoalEditor(context, ref, null),
                  ),
                );
              }

              final completedCount = goals.where((g) {
                final cur = _getCurrentValue(
                    g.metricType, todayLog.valueOrNull, latestWeight.valueOrNull);
                return cur >= g.targetValue;
              }).length;

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SummaryHeader(
                      total: goals.length,
                      completed: completedCount,
                    ),
                    const SizedBox(height: 16),
                    ...goals.map((goal) {
                      final current = _getCurrentValue(
                        goal.metricType,
                        todayLog.valueOrNull,
                        latestWeight.valueOrNull,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _GoalCard(
                          goal: goal,
                          currentValue: current,
                          onEdit: () =>
                              _showGoalEditor(context, ref, goal),
                          onDelete: () =>
                              _confirmDelete(context, ref, goal),
                        ),
                      );
                    }),
                  ]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const SliverFillRemaining(
              child: Center(child: Text('Could not load goals')),
            ),
          ),
        ],
      ),
    );
  }

  double _getCurrentValue(
    String metricType,
    DailyLog? log,
    HealthMetric? weightMetric,
  ) {
    return switch (metricType) {
      'steps' => (log?.steps ?? 0).toDouble(),
      'water' => (log?.waterGlasses ?? 0).toDouble(),
      'calories' => (log?.caloriesConsumed ?? 0).toDouble(),
      'sleep' => (log?.sleepMinutes ?? 0).toDouble(),
      'weight' => weightMetric?.value ?? 0,
      _ => 0,
    };
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, HealthGoal goal) {
    final meta = _goalTypes.firstWhere(
      (t) => t.key == goal.metricType,
      orElse: () => _goalTypes.first,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Goal'),
        content: Text('Remove your ${meta.label.toLowerCase()} goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref.read(goalActionsProvider).delete(goal.id);
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _showGoalEditor(
      BuildContext context, WidgetRef ref, HealthGoal? existing) {
    final types = _goalTypes;
    var selectedType = existing?.metricType ?? types.first.key;
    final targetCtrl = TextEditingController(
      text: existing != null && existing.metricType != 'sleep'
          ? existing.targetValue.toStringAsFixed(
              existing.metricType == 'weight' ? 1 : 0)
          : '',
    );
    var sleepHours = existing?.metricType == 'sleep'
        ? existing!.targetValue.toInt() ~/ 60
        : 8;
    var sleepMinutes = existing?.metricType == 'sleep'
        ? existing!.targetValue.toInt() % 60
        : 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final meta = types.firstWhere((t) => t.key == selectedType);
          final isSleep = selectedType == 'sleep';
          final presets = _presets[selectedType];

          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24, 0, 24,
                MediaQuery.of(ctx).viewInsets.bottom + 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: meta.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(meta.icon, color: meta.color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              existing != null
                                  ? 'Edit ${meta.label} Goal'
                                  : 'New Goal',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (existing != null)
                              Text(
                                'Current target: ${_fmtGoalValue(existing)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Type selector (only for new goals)
                  if (existing == null) ...[
                    const Text('Choose metric',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: types.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final t = types[i];
                          final sel = t.key == selectedType;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setSheetState(() {
                                selectedType = t.key;
                                targetCtrl.clear();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              decoration: BoxDecoration(
                                color: sel
                                    ? t.color.withValues(alpha: 0.12)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: sel
                                      ? t.color
                                      : AppColors.surfaceBorder,
                                  width: sel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(t.icon, size: 16, color: sel ? t.color : AppColors.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    t.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: sel
                                          ? t.color
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Input section
                  if (isSleep) ...[
                    const Text('Target sleep duration',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StepperField(
                            value: sleepHours,
                            label: 'Hours',
                            min: 0,
                            max: 14,
                            color: meta.color,
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              setSheetState(() => sleepHours = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StepperField(
                            value: sleepMinutes,
                            label: 'Minutes',
                            min: 0,
                            max: 45,
                            step: 15,
                            color: meta.color,
                            onChanged: (v) {
                              HapticFeedback.selectionClick();
                              setSheetState(() => sleepMinutes = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bedtime_rounded,
                              size: 14, color: meta.color),
                          const SizedBox(width: 6),
                          Text(
                            _fmtSleep(sleepHours * 60 + sleepMinutes),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: meta.color,
                            ),
                          ),
                          Text(
                            '  target',
                            style: TextStyle(
                              fontSize: 12,
                              color: meta.color.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text('Target (${meta.unit})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 12),
                    TextField(
                      controller: targetCtrl,
                      autofocus: existing == null,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: meta.color,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted.withValues(alpha: 0.3),
                        ),
                        suffixText: meta.unit,
                        suffixStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: meta.color.withValues(alpha: 0.3),
                              width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 18),
                      ),
                    ),

                    // Presets
                    if (presets != null && presets.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: presets.map((p) {
                          final active =
                              targetCtrl.text == p.value.toString();
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setSheetState(() {
                                targetCtrl.text =
                                    p.value.toStringAsFixed(
                                        selectedType == 'weight' ? 1 : 0);
                                targetCtrl.selection =
                                    TextSelection.collapsed(
                                        offset: targetCtrl.text.length);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: active
                                    ? meta.color.withValues(alpha: 0.12)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? meta.color
                                      : AppColors.surfaceBorder,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    p.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: active
                                          ? meta.color
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${p.value.toStringAsFixed(selectedType == 'weight' ? 1 : 0)} ${meta.unit}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: active
                                          ? meta.color.withValues(alpha: 0.7)
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: meta.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        double? val;
                        if (isSleep) {
                          val = (sleepHours * 60 + sleepMinutes).toDouble();
                        } else {
                          val = double.tryParse(targetCtrl.text.trim());
                        }
                        if (val == null || val <= 0) return;
                        HapticFeedback.mediumImpact();
                        ref.read(goalActionsProvider).upsert(
                              metricType: selectedType,
                              targetValue: val,
                              unit: meta.unit,
                            );
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        existing != null ? 'Update Goal' : 'Set Goal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Data ──────────────────────────────────────────────────────────────────

class _GoalMeta {
  final String key, label, unit;
  final IconData icon;
  final Color color;

  const _GoalMeta({
    required this.key,
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

final _goalTypes = [
  const _GoalMeta(
      key: 'steps',
      label: 'Steps',
      unit: 'steps',
      icon: Icons.directions_walk_rounded,
      color: AppColors.green),
  const _GoalMeta(
      key: 'water',
      label: 'Water',
      unit: 'glasses',
      icon: Icons.water_drop_rounded,
      color: Color(0xFF4FC3F7)),
  const _GoalMeta(
      key: 'calories',
      label: 'Calories',
      unit: 'kcal',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFFF6B35)),
  const _GoalMeta(
      key: 'weight',
      label: 'Weight',
      unit: 'kg',
      icon: Icons.monitor_weight_rounded,
      color: AppColors.primary),
  const _GoalMeta(
      key: 'sleep',
      label: 'Sleep',
      unit: 'hrs',
      icon: Icons.bedtime_rounded,
      color: Color(0xFF6E8EF7)),
];

class _Preset {
  final String label;
  final double value;
  const _Preset(this.label, this.value);
}

final _presets = <String, List<_Preset>>{
  'steps': [
    const _Preset('Light', 5000),
    const _Preset('Active', 8000),
    const _Preset('Fit', 10000),
    const _Preset('Athlete', 15000),
  ],
  'water': [
    const _Preset('Low', 6),
    const _Preset('Normal', 8),
    const _Preset('Active', 10),
    const _Preset('High', 12),
  ],
  'calories': [
    const _Preset('Cut', 1500),
    const _Preset('Maintain', 2000),
    const _Preset('Build', 2500),
    const _Preset('Bulk', 3000),
  ],
  'weight': [
    const _Preset('55 kg', 55),
    const _Preset('65 kg', 65),
    const _Preset('75 kg', 75),
    const _Preset('85 kg', 85),
  ],
};

String _fmtSleep(int totalMin) {
  final h = totalMin ~/ 60;
  final m = totalMin % 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

String _fmtGoalValue(HealthGoal g) {
  if (g.metricType == 'sleep') return _fmtSleep(g.targetValue.toInt());
  if (g.metricType == 'weight') {
    return '${g.targetValue.toStringAsFixed(1)} ${g.unit}';
  }
  return '${g.targetValue.toStringAsFixed(0)} ${g.unit}';
}

// ─── Summary Header ────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  final int total, completed;
  const _SummaryHeader({required this.total, required this.completed});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (completed / total * 100).round() : 0;
    final allDone = completed == total && total > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: allDone
              ? [const Color(0xFFEAFBF0), const Color(0xFFE0F7E9)]
              : [const Color(0xFFF5F2FF), const Color(0xFFEEF3FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: allDone
              ? AppColors.green.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          ProgressRing(
            progress: total > 0 ? completed / total : 0,
            size: 52,
            strokeWidth: 5,
            color: allDone ? AppColors.green : AppColors.primary,
            backgroundColor: allDone
                ? AppColors.green.withValues(alpha: 0.12)
                : AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              '$pct%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: allDone ? AppColors.green : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allDone ? 'All goals hit!' : 'Today\'s Progress',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: allDone ? AppColors.green : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$completed of $total goals completed',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (allDone)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 18, color: AppColors.green),
            ),
        ],
      ),
    );
  }
}

// ─── Goal Card ─────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final HealthGoal goal;
  final double currentValue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.currentValue,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _goalTypes.firstWhere(
      (t) => t.key == goal.metricType,
      orElse: () => _goalTypes.first,
    );
    final progress = goal.targetValue > 0
        ? (currentValue / goal.targetValue).clamp(0.0, 1.0)
        : 0.0;
    final pct = (progress * 100).round();
    final isComplete = currentValue >= goal.targetValue;

    final statusLabel = isComplete
        ? 'Completed'
        : progress >= 0.7
            ? 'Almost there'
            : progress > 0
                ? 'In progress'
                : 'Not started';
    final statusColor =
        isComplete ? AppColors.green : (progress >= 0.7 ? AppColors.yellow : AppColors.textMuted);

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4)),
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          children: [
            // Color accent strip
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    meta.color.withValues(alpha: 0.6),
                    meta.color.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: meta.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(meta.icon, color: meta.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meta.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ProgressRing(
                        progress: progress,
                        size: 50,
                        strokeWidth: 5,
                        color: meta.color,
                        backgroundColor: meta.color.withValues(alpha: 0.1),
                        child: Text(
                          '$pct%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: meta.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Current / Target row
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _ValueCol(
                          label: 'Current',
                          value: goal.metricType == 'sleep'
                              ? _fmtSleep(currentValue.toInt())
                              : goal.metricType == 'weight'
                                  ? currentValue.toStringAsFixed(1)
                                  : currentValue.toStringAsFixed(0),
                          color: meta.color,
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: AppColors.divider,
                        ),
                        _ValueCol(
                          label: 'Target',
                          value: goal.metricType == 'sleep'
                              ? _fmtSleep(goal.targetValue.toInt())
                              : goal.metricType == 'weight'
                                  ? goal.targetValue.toStringAsFixed(1)
                                  : goal.targetValue.toStringAsFixed(0),
                          color: AppColors.textPrimary,
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: AppColors.divider,
                        ),
                        _ValueCol(
                          label: 'Remaining',
                          value: _remaining(goal, currentValue),
                          color: isComplete
                              ? AppColors.green
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      height: 7,
                      child: Stack(
                        children: [
                          Container(color: meta.color.withValues(alpha: 0.08)),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    meta.color.withValues(alpha: 0.7),
                                    meta.color,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Actions
                  Row(
                    children: [
                      if (goal.metricType != 'sleep')
                        Text(
                          goal.metricType == 'weight'
                              ? goal.unit
                              : '${goal.unit} / day',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: meta.color.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 12, color: meta.color),
                              const SizedBox(width: 4),
                              Text('Edit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: meta.color,
                                  )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 12, color: AppColors.red),
                              SizedBox(width: 4),
                              Text('Delete',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.red,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _remaining(HealthGoal g, double current) {
    final diff = g.targetValue - current;
    if (diff <= 0) return 'Done';
    if (g.metricType == 'sleep') return _fmtSleep(diff.toInt());
    if (g.metricType == 'weight') return diff.toStringAsFixed(1);
    return diff.toStringAsFixed(0);
  }
}

class _ValueCol extends StatelessWidget {
  final String label, value;
  final Color color;
  const _ValueCol(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.1)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.04),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flag_rounded,
                size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Set your first goal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your daily progress for steps,\nwater, calories, sleep & weight.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Goal',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 28),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Stepper Field ─────────────────────────────────────────────────────────

class _StepperField extends StatelessWidget {
  final int value, min, max, step;
  final String label;
  final Color color;
  final ValueChanged<int> onChanged;

  const _StepperField({
    required this.value,
    required this.label,
    required this.min,
    required this.max,
    this.step = 1,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text('$value',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: color)),
              ],
            ),
          ),
          Column(
            children: [
              _StepBtn(
                icon: Icons.add_rounded,
                enabled: value + step <= max,
                color: color,
                onTap: () => onChanged(value + step),
              ),
              const SizedBox(height: 4),
              _StepBtn(
                icon: Icons.remove_rounded,
                enabled: value - step >= min,
                color: color,
                onTap: () => onChanged(value - step),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.08)
              : AppColors.surfaceBorder.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16,
            color: enabled
                ? color
                : AppColors.textMuted.withValues(alpha: 0.3)),
      ),
    );
  }
}
