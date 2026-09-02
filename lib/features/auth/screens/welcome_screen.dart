import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/medical_disclaimer.dart';
import '../providers/auth_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      image: 'assets/3d_isometric/upload report.png',
      titleBold: 'Health',
      titleThin: 'Score',
      subtitle: 'AI-Powered Blood Analysis',
      description:
          'Upload your blood test report from any lab or clinic and '
          'get an instant health score powered by AI. Understand what '
          'every parameter means with clear, simple insights — no '
          'medical jargon.',
      features: [
        'Requires a blood test report from a lab or clinic',
        'Instant AI analysis of 50+ blood parameters',
        'Traffic-light indicators: Green, Yellow, Red',
      ],
    ),
    _PageData(
      image: 'assets/3d_isometric/Claymorphic.png',
      titleBold: 'Track',
      titleThin: '& Compare',
      subtitle: 'Your Health Over Time',
      description:
          'See how your health changes across reports. Compare past '
          'and present results side-by-side with beautiful trend '
          'charts and heatmaps.',
      features: [
        'Interactive trend graphs for every parameter',
        'Health heatmap to spot patterns at a glance',
        'Compare any two reports instantly',
      ],
    ),
    _PageData(
      image: 'assets/3d_isometric/family profile_6 people.png',
      titleBold: 'Family',
      titleThin: 'Plans',
      subtitle: 'Health for Everyone You Love',
      description:
          'Track health for up to 6 family members under one account. '
          'Each person gets their own profile, reports, trends and insights.',
      features: [
        'Plus — 2 profiles, unlimited reports, all features',
        'Family — 6 profiles, track your whole family',
        'Full history, trends, heatmap & export',
      ],
      isPremiumPage: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 20),
                child: TextButton(
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).completeOnboarding();
                    context.go('/');
                  },
                  child: Text(
                    isLastPage ? '' : 'Skip',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  return _WelcomePage(data: _pages[index]);
                },
              ),
            ),

            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.15),
                    ),
                  );
                }),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: isLastPage
                    ? _ClaimOfferButton(
                        onTap: () {
                          ref.read(authNotifierProvider.notifier).completeOnboarding();
                          context.push('/pricing');
                        },
                      )
                    : ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
              ),
            ),

            // Medical disclaimer
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: MedicalDisclaimer(compact: true),
            ),

            // "Continue without plan" on last page
            if (isLastPage)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextButton(
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).completeOnboarding();
                    context.go('/');
                  },
                  child: const Text(
                    'Continue with Free plan',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page data model
// ---------------------------------------------------------------------------
class _PageData {
  final String image;
  final String titleBold;
  final String titleThin;
  final String subtitle;
  final String description;
  final List<String> features;
  final bool isPremiumPage;

  const _PageData({
    required this.image,
    required this.titleBold,
    required this.titleThin,
    required this.subtitle,
    required this.description,
    required this.features,
    this.isPremiumPage = false,
  });
}

// ---------------------------------------------------------------------------
// Single welcome page
// ---------------------------------------------------------------------------
class _WelcomePage extends StatelessWidget {
  final _PageData data;

  const _WelcomePage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Claymorphic image card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                data.image,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title — Bold + Thin Inter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.titleBold,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data.titleThin,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w200,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            data.subtitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 14),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          // Feature list
          ...data.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: data.isPremiumPage
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : AppColors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        data.isPremiumPage
                            ? Icons.star_rounded
                            : Icons.check_rounded,
                        size: 13,
                        color: data.isPremiumPage
                            ? AppColors.primary
                            : AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Claim Offer button — gradient with shimmer
// ---------------------------------------------------------------------------
class _ClaimOfferButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ClaimOfferButton({required this.onTap});

  @override
  State<_ClaimOfferButton> createState() => _ClaimOfferButtonState();
}

class _ClaimOfferButtonState extends State<_ClaimOfferButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          final shimmerOffset = _shimmerController.value * 2 - 0.5;
          return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5F33E1),
                  Color(0xFF7C3AED),
                  Color(0xFF6D28D9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shimmer overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment(shimmerOffset - 0.3, 0),
                          end: Alignment(shimmerOffset + 0.3, 0),
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcOver,
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.01),
                      ),
                    ),
                  ),
                ),
                // Label
                const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_offer_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Claim Offer',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
