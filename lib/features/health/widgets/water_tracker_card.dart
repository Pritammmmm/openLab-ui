import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../providers/daily_log_provider.dart';
import 'health_card.dart';

const _maxGlasses = 12;

class WaterTrackerCard extends ConsumerStatefulWidget {
  const WaterTrackerCard({super.key});

  @override
  ConsumerState<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends ConsumerState<WaterTrackerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  double _lastProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    final todayLog = ref.watch(todayLogProvider);
    final glasses = todayLog.valueOrNull?.waterGlasses ?? 0;
    final goal = 8;
    final progress = (glasses / goal).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateTo(progress);
    });

    return HealthCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF29B6F6), Color(0xFF4FC3F7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Water',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'Goal: $goal glasses',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Glass count + controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleButton(
                icon: Icons.remove_rounded,
                onTap: glasses > 0
                    ? () =>
                        ref.read(dailyLogActionsProvider).removeWater()
                    : null,
              ),
              const SizedBox(width: 20),
              Column(
                children: [
                  Text(
                    '$glasses',
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'of $goal glasses',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              _CircleButton(
                icon: Icons.add_rounded,
                onTap: glasses < _maxGlasses
                    ? () =>
                        ref.read(dailyLogActionsProvider).addWater()
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bar
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, _) {
              return _WaterProgressBar(
                progress: _progressAnim.value,
                percent: percent,
                glasses: glasses,
                goal: goal,
              );
            },
          ),

          const SizedBox(height: 10),

          // Glass dots row
          _GlassDots(filled: glasses, total: goal),

          if (glasses >= goal) ...[
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 13, color: Color(0xFF0288D1)),
                    SizedBox(width: 4),
                    Text(
                      'Goal reached!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0288D1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF29B6F6).withValues(alpha: 0.1)
              : AppColors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? const Color(0xFF29B6F6).withValues(alpha: 0.3)
                : AppColors.surfaceBorder,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? const Color(0xFF0288D1) : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _WaterProgressBar extends StatelessWidget {
  final double progress;
  final int percent;
  final int glasses;
  final int goal;

  const _WaterProgressBar({
    required this.progress,
    required this.percent,
    required this.glasses,
    required this.goal,
  });

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
                color:
                    progress >= 1.0 ? const Color(0xFF0288D1) : const Color(0xFF29B6F6),
              ),
            ),
            Text(
              progress >= 1.0 ? 'Completed' : '$glasses / $goal glasses',
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
              painter: _WaterBarPainter(progress: progress),
            ),
          ),
        ),
      ],
    );
  }
}

class _WaterBarPainter extends CustomPainter {
  final double progress;

  _WaterBarPainter({required this.progress});

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
        ? const LinearGradient(
            colors: [Color(0xFF0288D1), Color(0xFF03A9F4)])
        : const LinearGradient(
            colors: [Color(0xFF29B6F6), Color(0xFF4FC3F7), Color(0xFF81D4FA)]);

    final fillPaint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, fillWidth, size.height));

    final fillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillWidth, size.height),
      const Radius.circular(7),
    );
    canvas.drawRRect(fillRect, fillPaint);

    if (progress > 0.02 && progress < 1.0) {
      final glowCenter = Offset(fillWidth - 2, size.height / 2);
      final glowPaint = Paint()
        ..color = const Color(0xFF29B6F6).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(glowCenter, 5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_WaterBarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GlassDots extends StatelessWidget {
  final int filled;
  final int total;

  const _GlassDots({required this.filled, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + i * 50),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isFilled ? 24 : 20,
          height: isFilled ? 24 : 20,
          decoration: BoxDecoration(
            color: isFilled
                ? const Color(0xFF29B6F6).withValues(alpha: 0.15)
                : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isFilled
                  ? const Color(0xFF29B6F6).withValues(alpha: 0.4)
                  : AppColors.surfaceBorder,
              width: isFilled ? 1.5 : 1,
            ),
          ),
          child: Icon(
            Icons.water_drop_rounded,
            size: isFilled ? 12 : 8,
            color: isFilled ? const Color(0xFF0288D1) : AppColors.textMuted.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}
