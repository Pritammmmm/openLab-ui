import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/report_provider.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String reportId;

  const ProcessingScreen({super.key, required this.reportId});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  Timer? _pollTimer;
  Timer? _stepTimer;
  int _currentStep = 0;
  bool _failed = false;
  String? _errorMessage;

  final _steps = [
    ('Reading your report...', Icons.document_scanner_rounded),
    ('Analyzing parameters...', Icons.biotech_rounded),
    ('Preparing your summary...', Icons.auto_awesome_rounded),
  ];

  final _healthTips = [
    'Staying hydrated helps maintain accurate blood test results.',
    'Regular exercise can improve many blood markers over time.',
    'Getting 7-8 hours of sleep supports healthy blood sugar levels.',
    'A balanced diet rich in fruits and vegetables boosts overall health.',
  ];

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startStepAnimation();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _stepTimer?.cancel();
    super.dispose();
  }

  void _startStepAnimation() {
    _stepTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        timer.cancel();
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
      (_) => _checkStatus(),
    );
  }

  Future<void> _checkStatus() async {
    try {
      final repo = ref.read(reportRepositoryProvider);
      final status = await repo.getReportStatus(widget.reportId);

      if (!mounted) return;

      if (status == 'completed') {
        _pollTimer?.cancel();
        context.pushReplacement('/results/${widget.reportId}');
      } else if (status == 'failed') {
        _pollTimer?.cancel();
        setState(() {
          _failed = true;
          _errorMessage = 'Analysis failed. Please try again.';
        });
      }
    } catch (e) {
      // Will retry on next poll
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipIndex =
        DateTime.now().millisecond % _healthTips.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analyzing Report'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              if (_failed) ...[
                const Icon(Icons.error_outline_rounded,
                    size: 64, color: AppColors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Something went wrong',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Try Again',
                  onPressed: () => context.go('/upload'),
                  icon: Icons.refresh_rounded,
                ),
              ] else ...[
                // Animated pulse
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  onEnd: () {},
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _steps[_currentStep].$2,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Step indicators
                ...List.generate(_steps.length, (index) {
                  final isActive = index <= _currentStep;
                  final isCurrent = index == _currentStep;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.surfaceBorder,
                            shape: BoxShape.circle,
                          ),
                          child: isActive
                              ? isCurrent
                                  ? const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded,
                                      size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _steps[index].$1,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: isActive
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const Spacer(),

              // Health tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: AppColors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Health Tip',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppColors.green,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _healthTips[tipIndex],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
