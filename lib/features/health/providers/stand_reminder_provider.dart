import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/stand_reminder_service.dart';

const _kActive = 'stand_reminder_active';
const _kInterval = 'stand_reminder_interval';
const _kStartedAt = 'stand_reminder_started_at';
const _kTotalSessions = 'stand_reminder_total_sessions';
const _kTotalMinutes = 'stand_reminder_total_minutes';

class StandReminderState {
  final bool isActive;
  final int intervalMinutes;
  final DateTime? startedAt;
  final int totalSessions;
  final int totalMinutesTracked;

  const StandReminderState({
    this.isActive = false,
    this.intervalMinutes = 30,
    this.startedAt,
    this.totalSessions = 0,
    this.totalMinutesTracked = 0,
  });

  StandReminderState copyWith({
    bool? isActive,
    int? intervalMinutes,
    DateTime? startedAt,
    bool clearStartedAt = false,
    int? totalSessions,
    int? totalMinutesTracked,
  }) =>
      StandReminderState(
        isActive: isActive ?? this.isActive,
        intervalMinutes: intervalMinutes ?? this.intervalMinutes,
        startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
        totalSessions: totalSessions ?? this.totalSessions,
        totalMinutesTracked: totalMinutesTracked ?? this.totalMinutesTracked,
      );

  Duration get elapsed =>
      startedAt != null ? DateTime.now().difference(startedAt!) : Duration.zero;
}

class StandReminderNotifier extends StateNotifier<StandReminderState> {
  StandReminderNotifier() : super(const StandReminderState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool(_kActive) ?? false;
    final interval = prefs.getInt(_kInterval) ?? 30;
    final startedMs = prefs.getInt(_kStartedAt);
    final sessions = prefs.getInt(_kTotalSessions) ?? 0;
    final minutes = prefs.getInt(_kTotalMinutes) ?? 0;

    state = StandReminderState(
      isActive: active,
      intervalMinutes: interval,
      startedAt: startedMs != null
          ? DateTime.fromMillisecondsSinceEpoch(startedMs)
          : null,
      totalSessions: sessions,
      totalMinutesTracked: minutes,
    );

    if (active) {
      await StandReminderService.instance
          .startReminders(intervalMinutes: interval);
    }
  }

  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setBool(_kActive, true);
    await prefs.setInt(_kStartedAt, now.millisecondsSinceEpoch);
    await prefs.setInt(
        _kTotalSessions, state.totalSessions + 1);

    state = state.copyWith(
      isActive: true,
      startedAt: now,
      totalSessions: state.totalSessions + 1,
    );

    await StandReminderService.instance
        .startReminders(intervalMinutes: state.intervalMinutes);
  }

  Future<void> stop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kActive, false);
    await prefs.remove(_kStartedAt);

    final elapsed = state.elapsed.inMinutes;
    final newTotal = state.totalMinutesTracked + elapsed;
    await prefs.setInt(_kTotalMinutes, newTotal);

    state = state.copyWith(
      isActive: false,
      clearStartedAt: true,
      totalMinutesTracked: newTotal,
    );

    await StandReminderService.instance.cancelReminders();
  }

  Future<void> setInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kInterval, minutes);
    state = state.copyWith(intervalMinutes: minutes);

    if (state.isActive) {
      await StandReminderService.instance
          .startReminders(intervalMinutes: minutes);
    }
  }
}

final standReminderProvider =
    StateNotifierProvider<StandReminderNotifier, StandReminderState>(
  (_) => StandReminderNotifier(),
);
