import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../../history/providers/history_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../trends/providers/parameter_trend_provider.dart';
import '../providers/report_provider.dart';

// ─── Verified health & nutrition facts ───────────────────────────────
const _healthFacts = [
  (
    'Guava contains nearly 4× more Vitamin C than an orange — about 228 mg per fruit.',
    'Vitamin C',
  ),
  (
    'Your body produces roughly 2 million red blood cells every single second.',
    'Blood Cells',
  ),
  (
    'Hemoglobin carries about 97% of all oxygen transported in your blood.',
    'Hemoglobin',
  ),
  (
    'The average adult body contains approximately 5 liters (1.3 gallons) of blood.',
    'Blood Volume',
  ),
  (
    'Platelets have a short lifespan — they survive only 8 to 10 days before being replaced.',
    'Platelets',
  ),
  (
    'Iron from animal sources (heme iron) is absorbed 2–3× more efficiently than plant-based iron.',
    'Iron Absorption',
  ),
  (
    'Vitamin D is essential for calcium absorption — without it, your body absorbs only 10–15% of dietary calcium.',
    'Vitamin D',
  ),
  (
    'Mild dehydration can raise blood sugar readings by concentrating glucose in a smaller blood volume.',
    'Hydration',
  ),
  (
    'A single drop of blood contains roughly 250 million red blood cells and 400,000 white blood cells.',
    'Blood Composition',
  ),
  (
    'Fasting for 8–12 hours before a blood test gives the most accurate lipid and glucose readings.',
    'Lab Accuracy',
  ),
  (
    'Spinach is rich in iron, but its oxalates reduce absorption — pair it with Vitamin C to boost uptake.',
    'Nutrition Tip',
  ),
  (
    'Bananas provide about 422 mg of potassium each — roughly 9% of your daily recommended intake.',
    'Potassium',
  ),
  (
    'White blood cells make up less than 1% of your blood but are your body\'s primary defense system.',
    'Immunity',
  ),
  (
    'Vitamin B12 is critical for red blood cell formation — deficiency can cause megaloblastic anemia.',
    'Vitamin B12',
  ),
  (
    'Your liver filters about 1.4 liters of blood every minute and produces 800–1,000 mL of bile daily.',
    'Liver Function',
  ),
  (
    'Dark chocolate (70%+ cocoa) contains more iron per gram than beef — about 11.9 mg per 100 g.',
    'Iron Sources',
  ),
  (
    'Chronic stress can elevate cortisol, which may increase blood sugar and suppress immune function.',
    'Stress & Health',
  ),
  (
    'Omega-3 fatty acids from fish can lower triglyceride levels by 15–30% when consumed regularly.',
    'Heart Health',
  ),
];

class ProcessingScreen extends ConsumerStatefulWidget {
  final String reportId;

  const ProcessingScreen({super.key, required this.reportId});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen>
    with TickerProviderStateMixin {
  Timer? _pollTimer;
  Timer? _stepTimer;
  Timer? _factTimer;
  int _currentStep = 0;
  int _currentFact = 0;
  bool _failed = false;
  String? _errorMessage;

  late final AnimationController _progressController;
  late final AnimationController _pulseController;
  late final AnimationController _factFadeController;

  static const _steps = [
    ('Uploading your report', Icons.cloud_upload_outlined),
    ('Scanning document', Icons.document_scanner_outlined),
    ('Extracting text data', Icons.text_snippet_outlined),
    ('Identifying parameters', Icons.search_rounded),
    ('Matching reference ranges', Icons.compare_arrows_rounded),
    ('Analyzing health markers', Icons.biotech_outlined),
    ('Generating insights', Icons.auto_awesome_outlined),
    ('Preparing your summary', Icons.assignment_outlined),
  ];

  @override
  void initState() {
    super.initState();

    // Pick a random starting fact
    _currentFact = Random().nextInt(_healthFacts.length);

    // Smooth overall progress bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..forward();

    // Pulse animation for the active step icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Fact crossfade
    _factFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0,
    );

    _startPolling();
    _startStepAnimation();
    _startFactRotation();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _stepTimer?.cancel();
    _factTimer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _factFadeController.dispose();
    super.dispose();
  }

  void _startStepAnimation() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (!mounted) return;
      if (_currentStep < _steps.length - 1) {
        setState(() => _currentStep++);
      } else {
        timer.cancel();
      }
    });
  }

  void _startFactRotation() {
    _factTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      if (!mounted) return;
      // Fade out
      await _factFadeController.reverse();
      if (!mounted) return;
      setState(() {
        _currentFact = (_currentFact + 1) % _healthFacts.length;
      });
      // Fade in
      _factFadeController.forward();
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 2500),
      (_) => _checkStatus(),
    );
  }

  String _userFriendlyError(String? serverError) {
    if (serverError == null) return 'Something went wrong. Please try again.';
    if (serverError.contains('NOT_BLOOD_REPORT')) {
      return 'This image doesn\'t appear to be a blood test report. Please upload a clear photo or PDF of a lab report with test results.';
    }
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
        ref.invalidate(latestReportProvider);
        ref.invalidate(latestFullReportProvider);
        ref.invalidate(trendPreviewProvider);
        ref.invalidate(historyNotifierProvider);
        context.pushReplacement('/results/${widget.reportId}');
      } else if (status == 'failed') {
        _pollTimer?.cancel();
        final serverError = statusData['errorMessage'] as String?;
        setState(() {
          _failed = true;
          _errorMessage = _userFriendlyError(serverError);
        });
      }
    } catch (_) {
      // Will retry on next poll
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analyzing Report'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _failed ? _buildFailedState() : _buildProcessingState(),
      ),
    );
  }

  // ─── Processing UI ──────────────────────────────────────────────────
  Widget _buildProcessingState() {
    final fact = _healthFacts[_currentFact];

    return Column(
      children: [
        // Top progress bar
        AnimatedBuilder(
          animation: _progressController,
          builder: (_, _) => LinearProgressIndicator(
            value: _progressController.value,
            minHeight: 3,
            backgroundColor: AppColors.surfaceBorder,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            children: [
              // Hero section
              _buildHeroSection(),
              const SizedBox(height: 24),

              // Steps list
              _buildStepsList(),
              const SizedBox(height: 24),

              // Did you know card
              _buildFactCard(fact),
              const SizedBox(height: 20),

              const MedicalDisclaimer(compact: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Animated processing icon
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, child) {
            final scale = 1.0 + (_pulseController.value * 0.06);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This usually takes 20–30 seconds',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_steps.length, (i) {
          final isDone = i < _currentStep;
          final isCurrent = i == _currentStep;
          final isPending = i > _currentStep;

          return Column(
            children: [
              if (i > 0)
                // Connector line
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 2,
                      height: 20,
                      color: isDone
                          ? AppColors.green.withValues(alpha: 0.4)
                          : AppColors.surfaceBorder,
                    ),
                  ),
                ),
              Row(
                children: [
                  // Step indicator circle
                  _buildStepCircle(isDone, isCurrent),
                  const SizedBox(width: 14),
                  // Step label
                  Expanded(
                    child: Text(
                      _steps[i].$1,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isPending
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  // Step icon
                  Icon(
                    _steps[i].$2,
                    size: 18,
                    color: isDone
                        ? AppColors.green
                        : isCurrent
                            ? AppColors.primary
                            : AppColors.textMuted.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStepCircle(bool isDone, bool isCurrent) {
    if (isDone) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
      );
    }

    if (isCurrent) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: const Padding(
          padding: EdgeInsets.all(5),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      );
    }

    // Pending
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceBorder.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textMuted.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildFactCard((String fact, String tag) data) {
    return FadeTransition(
      opacity: _factFadeController,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Did you know?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data.$2,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Failed state ───────────────────────────────────────────────────
  Widget _buildFailedState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analysis Failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips for best results',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _tipRow('Use a clear, well-lit photo of the report'),
                _tipRow('Make sure all text and numbers are readable'),
                _tipRow('Include the full report, not a cropped section'),
                _tipRow('PDF files usually give the best results'),
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
          const Spacer(),
        ],
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_outline_rounded,
                size: 16, color: AppColors.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
