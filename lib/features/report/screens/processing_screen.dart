import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/isometric_icon.dart';
import '../../home/providers/home_provider.dart';
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

  Widget _tipRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline_rounded,
                size: 16, color: AppColors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _userFriendlyError(String? serverError) {
    if (serverError == null) return 'Something went wrong. Please try again.';

    if (serverError.contains('No valid parameters extracted') ||
        serverError.contains('No valid parameters could be extracted')) {
      return 'We couldn\'t find any medical data in this file. Please upload a clear photo or PDF of your blood test report.';
    }
    if (serverError.contains('matched the master catalog')) {
      return 'The report could not be read properly. Make sure the image is clear and shows a complete blood test report.';
    }
    if (serverError.contains('429') || serverError.contains('quota')) {
      return 'Our analysis service is temporarily busy. Please try again in a few minutes.';
    }
    if (serverError.contains('download') || serverError.contains('Cloudinary')) {
      return 'There was a problem processing your file. Please try uploading again.';
    }

    return 'Analysis failed. Please try again with a clear report image or PDF.';
  }

  Future<void> _checkStatus() async {
    try {
      final repo = ref.read(reportRepositoryProvider);
      final statusData = await repo.getReportStatus(widget.reportId);

      if (!mounted) return;

      final status = statusData['status'] as String? ?? 'processing';

      if (status == 'completed') {
        _pollTimer?.cancel();
        // Invalidate home screen providers so health score reflects the new report
        ref.invalidate(latestReportProvider);
        ref.invalidate(latestFullReportProvider);
        context.pushReplacement('/results/${widget.reportId}');
      } else if (status == 'failed') {
        _pollTimer?.cancel();
        final serverError = statusData['errorMessage'] as String?;
        setState(() {
          _failed = true;
          _errorMessage = _userFriendlyError(serverError);
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
                const IsometricIcon(
                  icon: Icons.error_outline_rounded,
                  size: 80,
                  color: AppColors.red,
                  animate: false,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips for best results:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _tipRow(context, 'Use a clear, well-lit photo of the report'),
                      _tipRow(context, 'Make sure all text and numbers are readable'),
                      _tipRow(context, 'Include the full report page, not a cropped section'),
                      _tipRow(context, 'PDF files usually give the best results'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Try Again',
                  onPressed: () => context.go('/upload'),
                  icon: Icons.refresh_rounded,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go Home'),
                ),
              ] else ...[
                // Animated 3D icon
                IsometricIcon(
                  icon: _steps[_currentStep].$2,
                  size: 100,
                  color: AppColors.primary,
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
                    const Icon3D(
                      icon: Icons.lightbulb_outline_rounded,
                      color: AppColors.green,
                      size: 36,
                    ),
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
