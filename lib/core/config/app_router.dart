import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/trends/screens/trends_screen.dart';
import '../../features/profile/screens/profile_setup_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/profile/screens/manage_profiles_screen.dart';
import '../../features/report/screens/upload_screen.dart';
import '../../features/report/screens/processing_screen.dart';
import '../../features/report/screens/results_screen.dart';
import '../../features/trends/screens/health_activity_screen.dart';
import '../../features/trends/screens/parameter_trend_screen.dart';
import '../../features/subscription/screens/pricing_screen.dart';
import '../../features/settings/screens/support_screen.dart';
import '../../features/settings/screens/privacy_policy_screen.dart';
import '../../features/medicine/screens/medicine_screen.dart';
import '../../features/health/screens/health_dashboard_screen.dart';
import '../../features/health/screens/health_goals_screen.dart';
import '../../features/health/screens/health_food_tracker_screen.dart';
import '../../features/health/screens/health_water_tracker_screen.dart';
import '../../features/health/screens/health_steps_tracker_screen.dart';
import '../../features/health/screens/blood_sugar_screen.dart';
import '../../features/health/screens/blood_pressure_screen.dart';
import '../../features/health/screens/weight_screen.dart';
import '../../features/health/screens/health_sync_settings_screen.dart';
import '../../features/health/screens/health_vitals_screen.dart';
import '../../features/health/screens/health_records_screen.dart';
import '../../features/health/screens/stand_reminder_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Listenable that notifies GoRouter when auth state changes,
/// so the router can re-evaluate redirects without being recreated.
class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable(this._ref) {
    _ref.listen<AuthState>(authNotifierProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthNotifierListenable(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final path = state.matchedLocation;
      final isPublicRoute = path == '/login' || path == '/privacy' || path == '/welcome' || path == '/onboarding';

      if (isLoading) {
        return isPublicRoute ? null : '/login';
      }

      if (!isAuthenticated && !isPublicRoute) {
        return '/login';
      }

      if (isAuthenticated && path == '/login') {
        return authState.isNewUser ? '/welcome' : '/';
      }

      // Redirect to welcome if onboarding not completed (e.g. app relaunch)
      if (isAuthenticated &&
          authState.isNewUser &&
          !isPublicRoute &&
          path != '/pricing') {
        return '/welcome';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/upload',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UploadScreen(),
      ),
      GoRoute(
        path: '/processing/:reportId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ProcessingScreen(
          reportId: state.pathParameters['reportId']!,
        ),
      ),
      GoRoute(
        path: '/results/:reportId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ResultsScreen(
          reportId: state.pathParameters['reportId']!,
        ),
      ),
      GoRoute(
        path: '/settings/profiles',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ManageProfilesScreen(),
      ),
      GoRoute(
        path: '/health-activity',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthActivityScreen(),
      ),
      GoRoute(
        path: '/parameter-trend',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ParameterTrendScreen(),
      ),
      GoRoute(
        path: '/pricing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: '/support',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/privacy',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/trends',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TrendsScreen(),
      ),
      GoRoute(
        path: '/medicine',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MedicineScreen(),
      ),
      GoRoute(
        path: '/health/goals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthGoalsScreen(),
      ),
      GoRoute(
        path: '/health/food',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthFoodTrackerScreen(),
      ),
      GoRoute(
        path: '/health/water',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthWaterTrackerScreen(),
      ),
      GoRoute(
        path: '/health/steps',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthStepsTrackerScreen(),
      ),
      GoRoute(
        path: '/health/blood-sugar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BloodSugarScreen(),
      ),
      GoRoute(
        path: '/health/blood-pressure',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BloodPressureScreen(),
      ),
      GoRoute(
        path: '/health/weight',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WeightScreen(),
      ),
      GoRoute(
        path: '/health/sync-settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthSyncSettingsScreen(),
      ),
      GoRoute(
        path: '/health/vitals',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthVitalsScreen(),
      ),
      GoRoute(
        path: '/health/records',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HealthRecordsScreen(),
      ),
      GoRoute(
        path: '/health/stand-reminder',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const StandReminderScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNav(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/health',
            builder: (context, state) => const HealthDashboardScreen(),
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNav({super.key, required this.child});

  /// Global key so any child screen can open the drawer.
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Toggle to hide the nav bar (e.g. when a bottom sheet is open).
  static final navBarVisible = ValueNotifier<bool>(true);

  static int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/health')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      key: scaffoldKey,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      drawer: const SettingsDrawer(),
      body: Stack(
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: ValueListenableBuilder<bool>(
              valueListenable: ScaffoldWithNav.navBarVisible,
              builder: (_, visible, child) => AnimatedOpacity(
                opacity: visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !visible,
                  child: child,
                ),
              ),
              child: FloatingNavBar(
                currentIndex: index,
                onTabChanged: (i) {
                  switch (i) {
                    case 0:
                      context.go('/');
                    case 1:
                      context.go('/history');
                    case 2:
                      context.go('/health');
                  }
                },
                onUploadTap: () => context.push('/upload'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating dark pill nav bar with isometric upload button
// ─────────────────────────────────────────────────────────────────────────────

const _pillBg = Color(0xF2F5F5F7);
const _accentPurple = Color(0xFF7C5CBF);
const _inactiveGrey = Color(0xFF8E8E93);
const _activeText = Color(0xFF1D1D1F);

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onUploadTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main pill segment
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _pillBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 36,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavTabItem(
                      icon: Icons.grid_view_rounded,
                      label: 'Dashboard',
                      isActive: currentIndex == 0,
                      onTap: () => onTabChanged(0),
                    ),
                    const SizedBox(width: 4),
                    _NavTabItem(
                      icon: Icons.access_time_rounded,
                      label: 'History',
                      isActive: currentIndex == 1,
                      onTap: () => onTabChanged(1),
                    ),
                    const SizedBox(width: 4),
                    _NavTabItem(
                      icon: Icons.favorite_rounded,
                      label: 'Health',
                      isActive: currentIndex == 2,
                      onTap: () => onTabChanged(2),
                    ),
                  ],
                );
              },
            ),
          ),
          // Push upload button to the right
          const Spacer(),
          // Circular upload button
          _IsometricUploadButton(onTap: onUploadTap),
        ],
      ),
    );
  }
}

class _NavTabItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavTabItem> createState() => _NavTabItemState();
}

class _NavTabItemState extends State<_NavTabItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));

    if (widget.isActive) {
      _bounceController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _NavTabItem old) {
    super.didUpdateWidget(old);
    if (!old.isActive && widget.isActive) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: widget.isActive ? 16 : 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: widget.isActive
              ? Colors.white
              : Colors.transparent,
          border: widget.isActive
              ? Border.all(
                  color: Colors.black.withValues(alpha: 0.06),
                  width: 0.5,
                )
              : null,
          boxShadow: widget.isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 24,
              color: widget.isActive ? _activeText : _inactiveGrey,
            ),
            AnimatedBuilder(
              animation: _bounceAnim,
              builder: (context, child) {
                final show = widget.isActive;
                final scale = show ? _bounceAnim.value : 0.0;
                final width = show ? 8.0 + (widget.label.length * 8.5) : 0.0;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: width,
                  child: scale > 0
                      ? Transform.scale(
                          scale: scale.clamp(0.0, 1.15),
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              widget.label,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _activeText,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _IsometricUploadButton extends StatefulWidget {
  final VoidCallback onTap;

  const _IsometricUploadButton({required this.onTap});

  @override
  State<_IsometricUploadButton> createState() => _IsometricUploadButtonState();
}

class _IsometricUploadButtonState extends State<_IsometricUploadButton>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnim;
  late AnimationController _shineController;
  bool _showGlow = false;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    // Glass shine animation — sweeps every 2 seconds
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _startShineLoop();
  }

  void _startShineLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      await _shineController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _tapController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _tapController.forward();
    setState(() => _showGlow = true);
  }

  void _onTapUp(TapUpDetails _) {
    _tapController.reverse();
    setState(() => _showGlow = false);
    widget.onTap();
  }

  void _onTapCancel() {
    _tapController.reverse();
    setState(() => _showGlow = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Transform.translate(
          offset: const Offset(0, 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF7F7FA),
                  Color(0xFFEDEDF2),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 36,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: _accentPurple.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
                if (_showGlow)
                  BoxShadow(
                    color: _accentPurple.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                children: [
                  // Icon
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/ai-hospital.svg',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        _activeText,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  // Glass shine sweep
                  AnimatedBuilder(
                    animation: _shineController,
                    builder: (context, _) {
                      final t = _shineController.value;
                      return Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(
                            -80 + (t * 160),
                            0,
                          ),
                          child: Transform.rotate(
                            angle: 0.35,
                            child: Container(
                              width: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.white.withValues(alpha: 0.7),
                                    Colors.white.withValues(alpha: 0.15),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}