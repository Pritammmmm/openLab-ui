import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_theme.dart';
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
            path: '/trends',
            builder: (context, state) => const TrendsScreen(),
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
    if (location.startsWith('/trends')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      key: scaffoldKey,
      extendBody: true,
      drawer: const SettingsDrawer(),
      body: child,
      bottomNavigationBar: _GlassNavBar(
        currentIndex: index,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/');
            case 1:
              context.go('/history');
            case 2:
              context.go('/trends');
          }
        },
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.history_rounded, label: 'History'),
    (icon: Icons.show_chart_rounded, label: 'Trends'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 40,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth) / _items.length;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sliding pill indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      left: currentIndex * itemWidth + 4,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        width: itemWidth - 8,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                    ),
                    // Nav items
                    Row(
                      children: List.generate(_items.length, (i) {
                        final selected = i == currentIndex;
                        final item = _items[i];
                        return Expanded(
                          child: _NavItem(
                            icon: item.icon,
                            label: item.label,
                            selected: selected,
                            onTap: () => onTap(i),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.1), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _NavItem old) {
    super.didUpdateWidget(old);
    if (!old.selected && widget.selected) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.selected ? _scaleAnim.value : 1.0,
            child: child,
          );
        },
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Icon(
                  widget.icon,
                  size: widget.selected ? 26 : 23,
                  color: widget.selected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: widget.selected ? 11.5 : 10.5,
                  fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w400,
                  color: widget.selected ? AppColors.primary : AppColors.textMuted,
                  letterSpacing: widget.selected ? 0.2 : 0,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
