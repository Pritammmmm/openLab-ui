import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        if (next.isNewUser) {
          context.go('/welcome');
        } else {
          context.go('/');
        }
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Light gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0E8FF),
                  Color(0xFFFAF7FF),
                  Colors.white,
                  Color(0xFFF3EDFF),
                ],
                stops: [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),

          // Animated floating cell-like blobs
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, _) {
              final t = _blobController.value * 2 * math.pi;
              final h = MediaQuery.of(context).size.height;
              final w = MediaQuery.of(context).size.width;

              // Each cell: (baseX, baseY, size, coreColor, coreAlpha,
              //             outerColor, outerAlpha, freqX, freqY, ampX, ampY)
              // Using irrational frequency ratios so paths never visibly repeat
              return Stack(
                children: [
                  // Cell 1 — top right
                  _positionedCell(
                    x: w * 0.65 + 40 * math.sin(t * 7.0),
                    y: h * 0.02 + 35 * math.cos(t * 5.0 + 0.3),
                    diameter: 200,
                    core: const Color(0xFF5F33E1), coreA: 0.28,
                    outer: const Color(0xFF7B52F5), outerA: 0.10,
                  ),
                  // Cell 2 — bottom left
                  _positionedCell(
                    x: -30 + 45 * math.sin(t * 4.3 + 1.1),
                    y: h * 0.78 + 40 * math.cos(t * 6.1 + 0.7),
                    diameter: 190,
                    core: const Color(0xFF7C3AED), coreA: 0.26,
                    outer: const Color(0xFF8B5CF6), outerA: 0.08,
                  ),
                  // Cell 3 — mid left
                  _positionedCell(
                    x: -40 + 30 * math.cos(t * 5.7 + 2.4),
                    y: h * 0.32 + 35 * math.sin(t * 3.9 + 1.8),
                    diameter: 160,
                    core: const Color(0xFFA78BFA), coreA: 0.24,
                    outer: const Color(0xFFC4B5FD), outerA: 0.07,
                  ),
                  // Cell 4 — top left
                  _positionedCell(
                    x: w * 0.08 + 25 * math.sin(t * 6.3 + 3.5),
                    y: h * 0.08 + 20 * math.cos(t * 4.7 + 0.9),
                    diameter: 120,
                    core: const Color(0xFFDDD6FE), coreA: 0.34,
                    outer: const Color(0xFFEDE9FE), outerA: 0.12,
                  ),
                  // Cell 5 — bottom right
                  _positionedCell(
                    x: w * 0.72 + 28 * math.cos(t * 5.1 + 4.2),
                    y: h * 0.68 + 25 * math.sin(t * 7.3 + 2.1),
                    diameter: 110,
                    core: const Color(0xFFC084FC), coreA: 0.22,
                    outer: const Color(0xFFD8B4FE), outerA: 0.07,
                  ),
                  // Cell 6 — mid right
                  _positionedCell(
                    x: w * 0.78 + 35 * math.sin(t * 3.7 + 5.5),
                    y: h * 0.45 + 30 * math.cos(t * 5.3 + 1.3),
                    diameter: 140,
                    core: const Color(0xFF6D28D9), coreA: 0.20,
                    outer: const Color(0xFF7C3AED), outerA: 0.06,
                  ),
                  // Cell 7 — top center
                  _positionedCell(
                    x: w * 0.35 + 22 * math.cos(t * 8.1 + 0.6),
                    y: h * 0.05 + 18 * math.sin(t * 5.9 + 3.2),
                    diameter: 90,
                    core: const Color(0xFFA78BFA), coreA: 0.28,
                    outer: const Color(0xFFC4B5FD), outerA: 0.09,
                  ),
                  // Cell 8 — center
                  _positionedCell(
                    x: w * 0.25 + 25 * math.sin(t * 4.1 + 2.8),
                    y: h * 0.55 + 22 * math.cos(t * 6.7 + 4.5),
                    diameter: 80,
                    core: const Color(0xFFDDD6FE), coreA: 0.32,
                    outer: const Color(0xFFEDE9FE), outerA: 0.10,
                  ),
                  // Cell 9 — small, wandering left
                  _positionedCell(
                    x: w * 0.12 + 20 * math.cos(t * 7.7 + 1.4),
                    y: h * 0.62 + 18 * math.sin(t * 5.3 + 5.8),
                    diameter: 70,
                    core: const Color(0xFFC084FC), coreA: 0.30,
                    outer: const Color(0xFFD8B4FE), outerA: 0.08,
                  ),
                  // Cell 10 — tiny, bottom center
                  _positionedCell(
                    x: w * 0.55 + 18 * math.sin(t * 6.9 + 3.9),
                    y: h * 0.88 + 15 * math.cos(t * 4.3 + 2.6),
                    diameter: 60,
                    core: const Color(0xFF8B5CF6), coreA: 0.26,
                    outer: const Color(0xFFA78BFA), outerA: 0.08,
                  ),
                  // Cell 11 — tiny, mid right
                  _positionedCell(
                    x: w * 0.88 + 15 * math.cos(t * 8.3 + 5.1),
                    y: h * 0.25 + 16 * math.sin(t * 6.1 + 0.4),
                    diameter: 55,
                    core: const Color(0xFFDDD6FE), coreA: 0.35,
                    outer: const Color(0xFFEDE9FE), outerA: 0.12,
                  ),
                ],
              );
            },
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo
                  Lottie.asset(
                    'assets/lottie/intro icon.json',
                    width: 130,
                    height: 130,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 28),

                  // App name
                  Text(
                    AppConfig.appName,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    AppConfig.appTagline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Feature pills
                  const _FeaturePills(),

                  const Spacer(flex: 3),

                  // --- Sign-in section ---
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.surfaceBorder,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Get started',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textMuted,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.surfaceBorder,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Google Sign-In button
                  _SignInButton(
                    isLoading: isLoading,
                    onPressed: () {
                      ref
                          .read(authNotifierProvider.notifier)
                          .signInWithGoogle();
                    },
                  ),

                  // TODO: Uncomment when Facebook Developer Console is configured
                  // const SizedBox(height: 12),
                  // _FacebookSignInButton(
                  //   isLoading: isLoading,
                  //   onPressed: () {
                  //     ref
                  //         .read(authNotifierProvider.notifier)
                  //         .signInWithFacebook();
                  //   },
                  // ),

                  const SizedBox(height: 24),

                  // Terms & Privacy
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            height: 1.5,
                            fontSize: 11,
                          ),
                      children: [
                        const TextSpan(text: 'By signing in, you agree to our '),
                        TextSpan(
                          text: 'Terms',
                          style: const TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryLight,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/privacy'),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryLight,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/privacy'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feature pills
// ---------------------------------------------------------------------------
Widget _positionedCell({
  required double x,
  required double y,
  required double diameter,
  required Color core,
  required double coreA,
  required Color outer,
  required double outerA,
}) {
  return Positioned(
    left: x - diameter / 2,
    top: y - diameter / 2,
    child: Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: core.withValues(alpha: coreA * 0.35),
          width: 1.2,
        ),
        gradient: RadialGradient(
          colors: [
            core.withValues(alpha: coreA),
            core.withValues(alpha: coreA * 0.45),
            outer.withValues(alpha: outerA),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.5, 1.0],
        ),
      ),
    ),
  );
}

class _FeaturePills extends StatelessWidget {
  const _FeaturePills();

  @override
  Widget build(BuildContext context) {
    const features = ['AI Analysis', 'Health Trends', 'Family Profiles'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: features.map((label) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary.withValues(alpha: 0.06),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Google sign-in button
// ---------------------------------------------------------------------------
class _SignInButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SignInButton({required this.isLoading, required this.onPressed});

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _pressController.forward(),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              _pressController.reverse();
              widget.onPressed();
            },
      onTapCancel:
          widget.isLoading ? null : () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(
              color: AppColors.surfaceBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/google.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Google',
                      style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Facebook sign-in button (uncomment when ready)
// ---------------------------------------------------------------------------
// class _FacebookSignInButton extends StatelessWidget {
//   final bool isLoading;
//   final VoidCallback onPressed;
//
//   const _FacebookSignInButton({
//     required this.isLoading,
//     required this.onPressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: OutlinedButton(
//         onPressed: isLoading ? null : onPressed,
//         style: OutlinedButton.styleFrom(
//           backgroundColor: const Color(0xFF1877F2),
//           side: const BorderSide(color: Color(0xFF1877F2)),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         child: isLoading
//             ? const SizedBox(
//                 width: 22,
//                 height: 22,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2.5,
//                   color: Colors.white70,
//                 ),
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.facebook, color: Colors.white, size: 22),
//                   const SizedBox(width: 12),
//                   Text(
//                     'Continue with Facebook',
//                     style: Theme.of(context).textTheme.labelLarge?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }
