import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../providers/daily_log_provider.dart';
import '../providers/target_provider.dart';
import '../widgets/health_card.dart';
import '../widgets/water_glass_indicator.dart';

class HealthWaterTrackerScreen extends ConsumerStatefulWidget {
  const HealthWaterTrackerScreen({super.key});

  @override
  ConsumerState<HealthWaterTrackerScreen> createState() =>
      _HealthWaterTrackerScreenState();
}

class _HealthWaterTrackerScreenState
    extends ConsumerState<HealthWaterTrackerScreen>
    with SingleTickerProviderStateMixin {
  static const _maxGlasses = 20;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayLog = ref.watch(todayLogProvider);
    final targets = ref.watch(healthTargetsProvider).valueOrNull;
    final goal = targets?.water ?? 8;
    final glasses = todayLog.valueOrNull?.waterGlasses ?? 0;
    final progress = (glasses / goal).clamp(0.0, 1.0);
    final actions = ref.read(dailyLogActionsProvider);
    final canAdd = glasses < _maxGlasses;

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
          'Water Tracker',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            HealthCard(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4FC3F7).withValues(alpha: 0.06),
                  Colors.white,
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.1).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeOutBack,
                      ),
                    ),
                    child: Text(
                      '$glasses',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4FC3F7),
                      ),
                    ),
                  ),
                  Text(
                    'of $goal glasses',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor:
                          const Color(0xFF4FC3F7).withValues(alpha: 0.12),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF4FC3F7)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    glasses >= goal
                        ? 'Goal reached! Great job!'
                        : '${goal - glasses} more to reach your goal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: glasses >= goal
                          ? AppColors.green
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 28),
            WaterGlassIndicator(current: glasses, goal: goal),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleBtn(
                  icon: Icons.remove_rounded,
                  onTap: () => actions.removeWater(),
                  enabled: glasses > 0,
                ),
                const SizedBox(width: 32),
                _AddWaterBtn(
                  onTap: () {
                    if (canAdd) {
                      actions.addWater();
                      _pulseController.forward(from: 0);
                    }
                  },
                  enabled: canAdd,
                ),
                const SizedBox(width: 32),
                _CircleBtn(
                  icon: Icons.refresh_rounded,
                  onTap: () => actions.resetWater(),
                  enabled: glasses > 0,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AddWaterBtn extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;

  const _AddWaterBtn({required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 22),
        ),
      ),
    );
  }
}
