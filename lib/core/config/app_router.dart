import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
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

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Listenable that notifies GoRouter when auth state changes,
/// so the router can re-evaluate redirects without being recreated.
class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable(this._ref) {
    _ref.listen<AuthState>(authNotifierProvider, (_, __) {
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
      final isLoginRoute = state.matchedLocation == '/login';

      if (isLoading) {
        return isLoginRoute ? null : '/login';
      }

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      if (isAuthenticated && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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

  static int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/') return 0;
    if (location.startsWith('/history')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      key: scaffoldKey,
      extendBody: true,
      drawer: const SettingsDrawer(),
      body: Stack(
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: FloatingNavBar(
              currentIndex: index,
              onTabChanged: (i) {
                switch (i) {
                  case 0:
                    context.go('/');
                  case 1:
                    context.go('/history');
                }
              },
              onUploadTap: () => context.push('/upload'),
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
const _accentDark = Color(0xFF5A3E9E);
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
        children: [
          // Main pill segment
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _pillBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _showGlow = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
    setState(() => _showGlow = true);
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    setState(() => _showGlow = false);
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _pillBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
              if (_showGlow)
                BoxShadow(
                  color: _accentPurple.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 30,
            color: _accentPurple,
          ),
        ),
      ),
    );
  }
}

class _IsometricUploadIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Isometric base plane
    final basePaint = Paint()
      ..color = _accentDark
      ..style = PaintingStyle.fill;

    final basePath = Path()
      ..moveTo(cx, cy + 6)
      ..lineTo(cx + 10, cy + 2)
      ..lineTo(cx, cy - 2)
      ..lineTo(cx - 10, cy + 2)
      ..close();
    canvas.drawPath(basePath, basePaint);

    // Isometric base top face (lighter)
    final topFacePaint = Paint()
      ..color = _accentPurple.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final topFacePath = Path()
      ..moveTo(cx, cy - 2)
      ..lineTo(cx + 10, cy + 2)
      ..lineTo(cx + 10, cy)
      ..lineTo(cx, cy - 4)
      ..lineTo(cx - 10, cy)
      ..lineTo(cx - 10, cy + 2)
      ..close();
    canvas.drawPath(topFacePath, topFacePaint);

    // Arrow shaft
    final arrowPaint = Paint()
      ..color = _accentPurple
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx, cy - 2),
      Offset(cx, cy - 14),
      arrowPaint,
    );

    // Arrow head
    final headPaint = Paint()
      ..color = _accentPurple
      ..style = PaintingStyle.fill;

    final headPath = Path()
      ..moveTo(cx, cy - 18)
      ..lineTo(cx - 5, cy - 11)
      ..lineTo(cx + 5, cy - 11)
      ..close();
    canvas.drawPath(headPath, headPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
