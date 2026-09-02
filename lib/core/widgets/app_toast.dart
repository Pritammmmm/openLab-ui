import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

enum ToastType { success, error, warning, info }

class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    dismiss();

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastOverlay(
        message: message,
        subtitle: subtitle,
        type: type,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _current?.remove();
    _current = null;
  }

  static void success(BuildContext context, String message, {String? subtitle}) =>
      show(context, message: message, subtitle: subtitle, type: ToastType.success);

  static void error(BuildContext context, String message, {String? subtitle}) =>
      show(context, message: message, subtitle: subtitle, type: ToastType.error,
          duration: const Duration(seconds: 4));

  static void warning(BuildContext context, String message, {String? subtitle}) =>
      show(context, message: message, subtitle: subtitle, type: ToastType.warning);

  static void info(BuildContext context, String message, {String? subtitle}) =>
      show(context, message: message, subtitle: subtitle, type: ToastType.info);
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final String? subtitle;
  final ToastType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.message,
    this.subtitle,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ),
    );

    _controller.forward();
    _scheduleAutoDismiss();
  }

  void _scheduleAutoDismiss() {
    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).viewPadding.top;
    final config = _ToastConfig.fromType(widget.type);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: topPadding + 12 + (_slideAnimation.value * 80),
          left: 16,
          right: 16,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy < -100) _dismiss();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: config.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: config.accentColor.withValues(alpha: 0.15),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: config.accentColor.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: config.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      config.icon,
                      color: config.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.actionLabel != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        widget.onAction?.call();
                        _dismiss();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: config.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.actionLabel!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: config.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastConfig {
  final Color accentColor;
  final Color backgroundColor;
  final IconData icon;

  const _ToastConfig({
    required this.accentColor,
    required this.backgroundColor,
    required this.icon,
  });

  factory _ToastConfig.fromType(ToastType type) {
    return switch (type) {
      ToastType.success => const _ToastConfig(
          accentColor: AppColors.green,
          backgroundColor: Color(0xFFF4FDF7),
          icon: Icons.check_circle_rounded,
        ),
      ToastType.error => const _ToastConfig(
          accentColor: AppColors.red,
          backgroundColor: Color(0xFFFEF5F4),
          icon: Icons.error_rounded,
        ),
      ToastType.warning => const _ToastConfig(
          accentColor: AppColors.yellow,
          backgroundColor: Color(0xFFFFFBF0),
          icon: Icons.warning_amber_rounded,
        ),
      ToastType.info => const _ToastConfig(
          accentColor: AppColors.primary,
          backgroundColor: Color(0xFFF5F2FE),
          icon: Icons.info_rounded,
        ),
    };
  }
}
