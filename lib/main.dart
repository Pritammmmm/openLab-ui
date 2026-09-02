import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'features/health/data/health_database.dart';
import 'features/medicine/data/notification_service.dart';
import 'features/subscription/providers/subscription_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await initRevenueCat();
  HealthDatabase.instance;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: BloodWiseApp(),
    ),
  );

  // Heavy: tz.initializeTimeZones() parses the full tz database synchronously.
  // Defer to after the first frame so it doesn't block initial render.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.init();
  });
}
