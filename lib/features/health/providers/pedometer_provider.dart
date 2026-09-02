import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pedometer_step_service.dart';
import 'health_providers.dart';
import 'daily_log_provider.dart';
import 'health_sync_provider.dart';

final pedometerServiceProvider = Provider<PedometerStepService>((ref) {
  final db = ref.watch(healthDatabaseProvider);
  final service = PedometerStepService(db);
  ref.onDispose(() => service.dispose());
  return service;
});

final sensorStepCountProvider = StreamProvider.autoDispose<int>((ref) {
  final service = ref.watch(pedometerServiceProvider);
  if (!service.isRunning) return Stream.value(0);
  return service.todaySensorSteps;
});

enum StepSource { healthConnect, sensor, manual, none }

final effectiveStepsProvider = Provider.autoDispose<({int steps, StepSource source})>((ref) {
  final todayLog = ref.watch(todayLogProvider).valueOrNull;
  final sensorSteps = ref.watch(sensorStepCountProvider).valueOrNull ?? 0;

  final dbSteps = todayLog?.steps ?? 0;
  final dbSource = todayLog?.source ?? 'manual';

  // The DB already has the max of HC and sensor from write-time merge.
  // But the sensor stream may have advanced since last DB write.
  final effectiveSteps = max(dbSteps, sensorSteps);

  StepSource source;
  if (effectiveSteps == 0) {
    source = StepSource.none;
  } else if (sensorSteps > dbSteps) {
    source = StepSource.sensor;
  } else if (dbSource == 'health_connect') {
    source = StepSource.healthConnect;
  } else if (dbSource == 'sensor') {
    source = StepSource.sensor;
  } else {
    source = StepSource.manual;
  }

  return (steps: effectiveSteps, source: source);
});

final pedometerToggleProvider =
    AsyncNotifierProvider<PedometerToggleNotifier, bool>(
        PedometerToggleNotifier.new);

class PedometerToggleNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final enabled = await PedometerStepService.isEnabled();
    if (enabled) {
      _startService();
    }
    return enabled;
  }

  Future<void> toggle(bool enable) async {
    final service = ref.read(pedometerServiceProvider);

    if (enable) {
      final granted = await service.requestPermission();
      if (!granted) {
        debugPrint('[Pedometer] Permission denied, not enabling');
        state = const AsyncData(false);
        return;
      }
      await PedometerStepService.setEnabled(true);
      await service.start();
      state = const AsyncData(true);
    } else {
      await PedometerStepService.setEnabled(false);
      await service.stop();
      state = const AsyncData(false);
    }
  }

  void _startService() {
    Future.delayed(Duration.zero, () async {
      final service = ref.read(pedometerServiceProvider);
      final granted = await service.hasPermission();
      if (granted) {
        await service.start();
      } else {
        await PedometerStepService.setEnabled(false);
        state = const AsyncData(false);
      }
    });
  }

  Future<void> autoActivateIfNeeded() async {
    final syncState = ref.read(healthSyncProvider).valueOrNull;
    final currentlyEnabled = state.valueOrNull ?? false;

    if (currentlyEnabled) return;

    final hcUnavailable = syncState == null ||
        !syncState.healthConnectAvailable ||
        !syncState.anyEnabled;

    if (hcUnavailable) {
      debugPrint('[Pedometer] HC unavailable — auto-activating sensor fallback');
      await toggle(true);
    }
  }
}
