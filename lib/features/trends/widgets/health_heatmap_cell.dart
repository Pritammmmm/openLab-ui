import 'package:flutter/material.dart';
import '../utils/heatmap_mapper.dart';

/// Color palette for heatmap cells (light theme, premium).
class HeatmapColors {
  static const Color excellent = Color(0xFF22C55E);
  static const Color mild = Color(0xFFFACC15);
  static const Color attention = Color(0xFFFB923C);
  static const Color critical = Color(0xFFEF4444);
  static const Color empty = Color(0xFFE5E7EB);

  static Color fromLevel(HeatmapLevel level) {
    switch (level) {
      case HeatmapLevel.excellent:
        return excellent;
      case HeatmapLevel.mild:
        return mild;
      case HeatmapLevel.attention:
        return attention;
      case HeatmapLevel.critical:
        return critical;
      case HeatmapLevel.empty:
        return empty;
    }
  }
}

/// A single animated heatmap cell.
class HeatmapCellWidget extends StatelessWidget {
  final HeatmapLevel level;
  final double size;
  final double borderRadius;

  const HeatmapCellWidget({
    super.key,
    required this.level,
    this.size = 11,
    this.borderRadius = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: HeatmapColors.fromLevel(level),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Animated version that fades + scales in with a staggered delay.
class AnimatedHeatmapCell extends StatefulWidget {
  final HeatmapLevel level;
  final double size;
  final double borderRadius;
  final int delayMs;

  const AnimatedHeatmapCell({
    super.key,
    required this.level,
    this.size = 11,
    this.borderRadius = 3,
    this.delayMs = 0,
  });

  @override
  State<AnimatedHeatmapCell> createState() => _AnimatedHeatmapCellState();
}

class _AnimatedHeatmapCellState extends State<AnimatedHeatmapCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: HeatmapCellWidget(
          level: widget.level,
          size: widget.size,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}
