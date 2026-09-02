import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../providers/stand_reminder_provider.dart';

const _accentOrange = Color(0xFFFF9500);
const _accentTeal = Color(0xFF30D158);
const _accentBlue = Color(0xFF007AFF);

class StandReminderScreen extends ConsumerStatefulWidget {
  const StandReminderScreen({super.key});

  @override
  ConsumerState<StandReminderScreen> createState() =>
      _StandReminderScreenState();
}

class _StandReminderScreenState extends ConsumerState<StandReminderScreen>
    with TickerProviderStateMixin {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  late final AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTicker());
  }

  void _syncTicker() {
    final s = ref.read(standReminderProvider);
    if (s.isActive && s.startedAt != null) {
      _elapsed = DateTime.now().difference(s.startedAt!);
      _startTicker();
      _pulseCtrl.repeat(reverse: true);
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final s = ref.read(standReminderProvider);
      if (s.startedAt != null) {
        setState(() => _elapsed = DateTime.now().difference(s.startedAt!));
      }
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _pulseCtrl.stop();
    _pulseCtrl.reset();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(standReminderProvider);
    final notifier = ref.read(standReminderProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
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
              'Stand & Move',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero card
                _buildHeroCard(state, notifier),
                const SizedBox(height: 20),

                // Interval picker
                _buildIntervalSection(state, notifier),
                const SizedBox(height: 20),

                // Stats
                _buildStatsSection(state),
                const SizedBox(height: 20),

                // Tips
                _buildTipsSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero card ─────────────────────────────────────────────────────────

  Widget _buildHeroCard(
      StandReminderState state, StandReminderNotifier notifier) {
    final active = state.isActive;
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes % 60;
    final s = _elapsed.inSeconds % 60;
    final timeStr =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    final nextIn = active
        ? Duration(minutes: state.intervalMinutes) -
            Duration(seconds: _elapsed.inSeconds % (state.intervalMinutes * 60))
        : Duration.zero;
    final nextM = nextIn.inMinutes;
    final nextS = nextIn.inSeconds % 60;
    final ringProgress = active
        ? ((_elapsed.inSeconds % (state.intervalMinutes * 60)) /
                (state.intervalMinutes * 60))
            .clamp(0.0, 1.0)
        : 0.0;

    return FadeTransition(
      opacity: CurvedAnimation(
          parent: _entryCtrl, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(
            parent: _entryCtrl, curve: Curves.easeOutCubic)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: active
                  ? [const Color(0xFFFFF8F0), const Color(0xFFFFF3E6)]
                  : [const Color(0xFFF5F2FF), const Color(0xFFEEF3FF)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: active
                  ? _accentOrange.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: (active ? _accentOrange : AppColors.primary)
                    .withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? _accentOrange.withValues(alpha: 0.12)
                      : AppColors.textMuted.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: active ? _accentOrange : AppColors.textMuted,
                        shape: BoxShape.circle,
                        boxShadow: active
                            ? [
                                BoxShadow(
                                    color:
                                        _accentOrange.withValues(alpha: 0.4),
                                    blurRadius: 4)
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      active ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? _accentOrange : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Ring + timer
              ScaleTransition(
                scale: active ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _ReminderRingPainter(
                      progress: ringProgress,
                      isActive: active,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            active
                                ? Icons.directions_walk_rounded
                                : Icons.airline_seat_recline_normal_rounded,
                            size: 28,
                            color: active
                                ? _accentOrange
                                : AppColors.textMuted.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            active ? timeStr : '00:00:00',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: active
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted.withValues(alpha: 0.4),
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                              letterSpacing: 1.5,
                            ),
                          ),
                          if (active) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Next alert in ${nextM}m ${nextS}s',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _accentOrange.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Start/Stop button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    if (active) {
                      await notifier.stop();
                      _stopTicker();
                      setState(() => _elapsed = Duration.zero);
                    } else {
                      await notifier.start();
                      _syncTicker();
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        active ? AppColors.red : _accentOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        active ? 'Stop Reminder' : 'Start Reminder',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Interval section ──────────────────────────────────────────────────

  Widget _buildIntervalSection(
      StandReminderState state, StandReminderNotifier notifier) {
    const intervals = [15, 20, 30, 45, 60, 90];

    return _SectionCard(
      icon: Icons.timer_outlined,
      iconColor: _accentBlue,
      title: 'Reminder Interval',
      subtitle: 'How often should we remind you?',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: intervals.map((min) {
              final sel = state.intervalMinutes == min;
              final label = min >= 60 ? '${min ~/ 60}h' : '${min}m';
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.setInterval(min);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 42,
                  decoration: BoxDecoration(
                    color: sel
                        ? _accentBlue.withValues(alpha: 0.12)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel ? _accentBlue : AppColors.surfaceBorder,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: sel ? _accentBlue : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: _accentBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: _accentBlue.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'ll get a notification every ${state.intervalMinutes} min to stand up and walk.',
                    style: TextStyle(
                      fontSize: 11,
                      color: _accentBlue.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stats section ─────────────────────────────────────────────────────

  Widget _buildStatsSection(StandReminderState state) {
    final totalH = state.totalMinutesTracked ~/ 60;
    final totalM = state.totalMinutesTracked % 60;

    return _SectionCard(
      icon: Icons.bar_chart_rounded,
      iconColor: _accentTeal,
      title: 'Your Stats',
      subtitle: 'Lifetime activity',
      child: Row(
        children: [
          _StatTile(
            value: '${state.totalSessions}',
            label: 'Sessions',
            icon: Icons.repeat_rounded,
            color: _accentOrange,
          ),
          Container(width: 1, height: 44, color: AppColors.divider),
          _StatTile(
            value: totalH > 0 ? '${totalH}h ${totalM}m' : '${totalM}m',
            label: 'Time tracked',
            icon: Icons.schedule_rounded,
            color: _accentBlue,
          ),
          Container(width: 1, height: 44, color: AppColors.divider),
          _StatTile(
            value:
                '${state.totalSessions > 0 ? (state.totalMinutesTracked / state.totalSessions).round() : 0}m',
            label: 'Avg session',
            icon: Icons.trending_up_rounded,
            color: _accentTeal,
          ),
        ],
      ),
    );
  }

  // ─── Tips section ──────────────────────────────────────────────────────

  Widget _buildTipsSection() {
    const tips = [
      (Icons.directions_walk_rounded, 'Walk around', 'A 2-minute walk every 30 min reduces health risks.'),
      (Icons.self_improvement_rounded, 'Stretch', 'Simple stretches at your desk improve blood flow.'),
      (Icons.visibility_rounded, 'Eye rest', 'Follow the 20-20-20 rule: every 20 min, look 20 ft away for 20 sec.'),
      (Icons.water_drop_rounded, 'Hydrate', 'Use each break to drink water and stay hydrated.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Healthy Habits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
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
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _accentOrange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(tip.$1, size: 18, color: _accentOrange),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip.$2,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              )),
                          const SizedBox(height: 2),
                          Text(tip.$3,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                height: 1.3,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// ─── Section card wrapper ──────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Stat tile ─────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.0,
              )),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              )),
        ],
      ),
    );
  }
}

// ─── Ring painter ──────────────────────────────────────────────────────────

class _ReminderRingPainter extends CustomPainter {
  final double progress;
  final bool isActive;

  _ReminderRingPainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = isActive
            ? _accentOrange.withValues(alpha: 0.08)
            : AppColors.surfaceBorder.withValues(alpha: 0.5)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (!isActive || progress <= 0) return;

    // Active arc
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + 2 * pi,
      colors: const [
        Color(0xFFFF9500),
        Color(0xFFFF6B35),
        Color(0xFFFF2D55),
        Color(0xFFFF9500),
      ],
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient
            .createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // End glow
    final endAngle = -pi / 2 + sweepAngle;
    final dot = Offset(
        center.dx + radius * cos(endAngle),
        center.dy + radius * sin(endAngle));
    canvas.drawCircle(
      dot,
      5,
      Paint()
        ..color = _accentOrange.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(dot, 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ReminderRingPainter old) =>
      old.progress != progress || old.isActive != isActive;
}
