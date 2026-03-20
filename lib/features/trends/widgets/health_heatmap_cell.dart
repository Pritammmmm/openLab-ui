import 'package:flutter/material.dart';
import '../utils/heatmap_mapper.dart';

/// GitHub-style green gradient palette.
class HeatmapColors {
  static const Color excellent = Color(0xFF216E39);
  static const Color high = Color(0xFF30A14E);
  static const Color medium = Color(0xFF40C463);
  static const Color low = Color(0xFF9BE9A8);
  static const Color empty = Color(0xFFEBEDF0);

  static Color fromLevel(HeatmapLevel level) {
    switch (level) {
      case HeatmapLevel.excellent:
        return excellent;
      case HeatmapLevel.high:
        return high;
      case HeatmapLevel.medium:
        return medium;
      case HeatmapLevel.low:
        return low;
      case HeatmapLevel.empty:
        return empty;
    }
  }
}

/// Static heatmap block (used in legends).
class HeatmapCellWidget extends StatelessWidget {
  final HeatmapLevel level;
  final double size;
  final double borderRadius;

  const HeatmapCellWidget({
    super.key,
    required this.level,
    this.size = 11,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final color = HeatmapColors.fromLevel(level);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Heatmap block with optional pulsing glow.
/// - Current month + active: pulsing glow (alive, still accepting uploads)
/// - Past month + active: static glow (score is final)
/// - Empty: plain gray, no glow
class GlowingHeatmapCell extends StatefulWidget {
  final HeatmapLevel level;
  final double width;
  final double height;
  final double borderRadius;
  final bool isCurrentMonth;

  const GlowingHeatmapCell({
    super.key,
    required this.level,
    required this.width,
    required this.height,
    this.borderRadius = 4,
    this.isCurrentMonth = false,
  });

  @override
  State<GlowingHeatmapCell> createState() => _GlowingHeatmapCellState();
}

class _GlowingHeatmapCellState extends State<GlowingHeatmapCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  bool get _shouldAnimate =>
      widget.isCurrentMonth && widget.level != HeatmapLevel.empty;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (_shouldAnimate) {
      _controller.repeat(reverse: true);
    }
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = HeatmapColors.fromLevel(widget.level);
    final isActive = widget.level != HeatmapLevel.empty;

    // Empty — plain gray
    if (!isActive) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    // Past month — static glow, no animation
    if (!widget.isCurrentMonth) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }

    // Current month — pulsing glow
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        final t = _glow.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25 + t * 0.35),
                blurRadius: 4 + t * 8,
                spreadRadius: t * 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
