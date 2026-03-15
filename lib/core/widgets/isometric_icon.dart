import 'package:flutter/material.dart';

/// A large 3D isometric-style icon with a floating animation.
/// Use for hero spots: empty states, onboarding, error pages.
class IsometricIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final bool animate;

  const IsometricIcon({
    super.key,
    required this.icon,
    this.size = 100,
    this.color = const Color(0xFF5F33E1),
    this.animate = true,
  });

  @override
  State<IsometricIcon> createState() => _IsometricIconState();
}

class _IsometricIconState extends State<IsometricIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    if (widget.animate) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final color = widget.color;
    final radius = s * 0.25;

    Widget icon = SizedBox(
      width: s + 10,
      height: s + 16,
      child: Stack(
        children: [
          // ── Ground shadow ──
          Positioned(
            bottom: 0,
            left: s * 0.15,
            right: s * 0.15,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // ── Depth face (offset darker layer) ──
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                color: Color.lerp(color, Colors.black, 0.35),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),

          // ── Main face with gradient ──
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(color, Colors.white, 0.25)!,
                    color,
                    Color.lerp(color, Colors.black, 0.08)!,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: s * 0.45,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // ── Glass highlight ──
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              width: s * 0.45,
              height: s * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius - 2),
                  topRight: Radius.circular(radius * 0.4),
                  bottomLeft: Radius.circular(radius * 0.4),
                  bottomRight: Radius.circular(radius),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.animate) {
      icon = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_controller.value);
          return Transform.translate(
            offset: Offset(0, -5 * t + 2.5),
            child: child,
          );
        },
        child: icon,
      );
    }

    return icon;
  }
}

/// A compact 3D-styled icon for cards, list items, and headers.
/// Renders a gradient box with glass highlight and depth shadow.
class Icon3D extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const Icon3D({
    super.key,
    required this.icon,
    this.size = 44,
    this.color = const Color(0xFF5F33E1),
  });

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    final iconSize = size * 0.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.2)!,
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Glass highlight
          Positioned(
            top: 2,
            left: 2,
            child: Container(
              width: size * 0.5,
              height: size * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius - 1),
                  topRight: Radius.circular(radius * 0.3),
                  bottomRight: Radius.circular(radius),
                ),
              ),
            ),
          ),
          Center(
            child: Icon(icon, size: iconSize, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
