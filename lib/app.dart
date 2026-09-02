import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_router.dart';
import 'core/config/app_theme.dart';
import 'core/config/app_config.dart';
import 'features/subscription/providers/subscription_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/health/providers/health_sync_provider.dart';
import 'features/health/providers/pedometer_provider.dart';

class BloodWiseApp extends ConsumerStatefulWidget {
  const BloodWiseApp({super.key});

  @override
  ConsumerState<BloodWiseApp> createState() => _BloodWiseAppState();
}

class _BloodWiseAppState extends ConsumerState<BloodWiseApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final authState = ref.read(authNotifierProvider);
      if (authState.status == AuthStatus.authenticated) {
        // Stagger resume work across frames to avoid a rebuild storm
        ref.invalidate(customerInfoProvider);
        ref.read(authNotifierProvider.notifier).refreshSubscription();
        Future.microtask(() {
          if (!mounted) return;
          ref.read(healthSyncProvider.notifier).autoSyncIfEnabled();
          ref.read(pedometerToggleProvider.notifier).autoActivateIfNeeded();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}