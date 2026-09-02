import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../providers/pedometer_provider.dart';
import '../providers/step_goal_provider.dart';
import 'health_card.dart';

class StepTrackerCard extends ConsumerStatefulWidget {
  const StepTrackerCard({super.key});

  @override
  ConsumerState<StepTrackerCard> createState() => _StepTrackerCardState();
}

class _StepTrackerCardState extends ConsumerState<StepTrackerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  double _lastProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    if ((target - _lastProgress).abs() < 0.001) return;
    _progressAnim = Tween<double>(begin: _lastProgress, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller
      ..reset()
      ..forward();
    _lastProgress = target;
  }

  @override
  Widget build(BuildContext context) {
    final effective = ref.watch(effectiveStepsProvider);
    final steps = effective.steps;
    final source = effective.source;
    final goal = ref.watch(stepGoalProvider).valueOrNull ?? 10000;

    final progress = (steps / goal).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateTo(progress);
    });

    return HealthCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Steps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showGoalDialog(context, goal),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flag_rounded,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        _formatNumber(goal),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Big step count
          Center(
            child: Column(
              children: [
                Text(
                  _formatNumber(steps),
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'of ${_formatNumber(goal)} steps',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Animated progress bar
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, _) {
              return _AnimatedProgressBar(
                progress: _progressAnim.value,
                percent: percent,
              );
            },
          ),

          const SizedBox(height: 10),

          // Source + completion row
          Row(
            children: [
              _SourceChip(source: source),
              const Spacer(),
              if (steps >= goal)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.greenBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 13, color: AppColors.green),
                      SizedBox(width: 4),
                      Text(
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
            ],
          ),
        ],
      ),
    );
  }

  void _showGoalDialog(BuildContext context, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());
    final presets = [5000, 8000, 10000, 12000, 15000];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Daily Step Goal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Set your daily target to stay active',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),

                // Preset chips
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: presets.map((v) {
                    final selected = controller.text == v.toString();
                    return GestureDetector(
                      onTap: () {
                        controller.text = v.toString();
                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _formatNumber(v),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Custom input
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: '10000',
                    hintStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted.withValues(alpha: 0.3),
                    ),
                    suffixText: 'steps',
                    suffixStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                ),

                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final value = int.tryParse(controller.text);
                      if (value != null && value >= 100) {
                        ref.read(stepGoalProvider.notifier).setGoal(value);
                        Navigator.of(ctx).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Set Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
        buffer.write(s[i]);
      }
      return buffer.toString();
    }
    return n.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated progress bar with gradient and glow
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final int percent;

  const _AnimatedProgressBar({required this.progress, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: progress >= 1.0 ? AppColors.green : AppColors.primary,
              ),
            ),
            Text(
              progress >= 1.0 ? 'Completed' : 'In progress',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CustomPaint(
              size: const Size(double.infinity, 10),
              painter: _ProgressBarPainter(
                progress: progress,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final double progress;

  _ProgressBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = const Color(0xFFF0F0F5)
      ..style = PaintingStyle.fill;

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(7),
    );
    canvas.drawRRect(bgRect, bgPaint);

    if (progress <= 0) return;

    final fillWidth = size.width * progress.clamp(0.0, 1.0);

    final gradient = progress >= 1.0
        ? const LinearGradient(colors: [Color(0xFF34C759), Color(0xFF30D158)])
        : const LinearGradient(
            colors: [Color(0xFF5F33E1), Color(0xFF7B52F5), Color(0xFF9B7BFF)]);

    final fillPaint = Paint()
      ..shader = gradient
          .createShader(Rect.fromLTWH(0, 0, fillWidth, size.height));

    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillWidth, size.height),
      const Radius.circular(7),
    );
    canvas.drawRRect(fillRect, fillPaint);

    // Glow at the leading edge
    if (progress > 0.02 && progress < 1.0) {
      final glowCenter = Offset(fillWidth - 2, size.height / 2);
      final glowPaint = Paint()
        ..color = const Color(0xFF7B52F5).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(glowCenter, 5, glowPaint);
    }

    // Running figure dots at the leading edge
    if (progress > 0.03 && progress < 1.0) {
      final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
      final x = fillWidth - 7;
      final cy = size.height / 2;
      canvas.drawCircle(Offset(x, cy - 2.5), 1.5, dotPaint);
      canvas.drawCircle(Offset(x, cy + 2.5), 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Source chip
// ─────────────────────────────────────────────────────────────────────────────

class _SourceChip extends StatelessWidget {
  final StepSource source;

  const _SourceChip({required this.source});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (source) {
      StepSource.healthConnect => (
          Icons.favorite_rounded,
          'Health Connect',
          const Color(0xFF4285F4)
        ),
      StepSource.sensor => (
          Icons.phone_android_rounded,
          'Phone sensor',
          const Color(0xFF4CAF50)
        ),
      StepSource.manual => (
          Icons.edit_rounded,
          'Manual',
          AppColors.textMuted
        ),
      StepSource.none => (
          Icons.remove_circle_outline_rounded,
          'No data yet',
          AppColors.textMuted
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
