import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'medicine_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    _setLocalTimezone();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request notification permission (Android 13+)
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    debugPrint('[NotifService] notification permission granted: $granted');

    // Request exact alarm permission (Android 14+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
    debugPrint('[NotifService] initialized, local tz: ${tz.local.name}');
  }

  /// Detect device timezone and set tz.local accordingly.
  void _setLocalTimezone() {
    try {
      // Get the system timezone offset and find matching tz location
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final tzName = now.timeZoneName;

      // Try common timezone names first
      final knownMappings = <String, String>{
        'IST': 'Asia/Kolkata',
        'EST': 'America/New_York',
        'EDT': 'America/New_York',
        'CST': 'America/Chicago',
        'CDT': 'America/Chicago',
        'MST': 'America/Denver',
        'MDT': 'America/Denver',
        'PST': 'America/Los_Angeles',
        'PDT': 'America/Los_Angeles',
        'GMT': 'Europe/London',
        'BST': 'Europe/London',
        'CET': 'Europe/Berlin',
        'CEST': 'Europe/Berlin',
        'JST': 'Asia/Tokyo',
        'KST': 'Asia/Seoul',
        'CST_CN': 'Asia/Shanghai',
        'AEST': 'Australia/Sydney',
        'AEDT': 'Australia/Sydney',
      };

      // Try direct timezone name match
      if (knownMappings.containsKey(tzName)) {
        tz.setLocalLocation(tz.getLocation(knownMappings[tzName]!));
        debugPrint('[NotifService] tz set via name mapping: ${knownMappings[tzName]}');
        return;
      }

      // Try the timezone name directly (works on some devices)
      try {
        tz.setLocalLocation(tz.getLocation(tzName));
        debugPrint('[NotifService] tz set directly: $tzName');
        return;
      } catch (_) {}

      // Fallback: match by offset
      final offsetHours = offset.inHours;
      final offsetMinutes = offset.inMinutes % 60;
      final fallbackMap = <int, String>{
        -12: 'Pacific/Baker_Island',
        -11: 'Pacific/Pago_Pago',
        -10: 'Pacific/Honolulu',
        -9: 'America/Anchorage',
        -8: 'America/Los_Angeles',
        -7: 'America/Denver',
        -6: 'America/Chicago',
        -5: 'America/New_York',
        -4: 'America/Halifax',
        -3: 'America/Sao_Paulo',
        -2: 'Atlantic/South_Georgia',
        -1: 'Atlantic/Azores',
        0: 'Europe/London',
        1: 'Europe/Berlin',
        2: 'Europe/Helsinki',
        3: 'Europe/Moscow',
        4: 'Asia/Dubai',
        5: 'Asia/Karachi',
        6: 'Asia/Dhaka',
        7: 'Asia/Bangkok',
        8: 'Asia/Shanghai',
        9: 'Asia/Tokyo',
        10: 'Australia/Brisbane',
        11: 'Pacific/Noumea',
        12: 'Pacific/Auckland',
      };

      // Handle IST (UTC+5:30) specifically
      if (offsetHours == 5 && offsetMinutes == 30) {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
        debugPrint('[NotifService] tz set via offset: Asia/Kolkata (UTC+5:30)');
        return;
      }
      if (offsetHours == 9 && offsetMinutes == 30) {
        tz.setLocalLocation(tz.getLocation('Australia/Darwin'));
        debugPrint('[NotifService] tz set via offset: Australia/Darwin (UTC+9:30)');
        return;
      }

      if (fallbackMap.containsKey(offsetHours)) {
        tz.setLocalLocation(tz.getLocation(fallbackMap[offsetHours]!));
        debugPrint('[NotifService] tz set via offset fallback: ${fallbackMap[offsetHours]}');
        return;
      }

      debugPrint('[NotifService] WARNING: could not determine timezone, using UTC');
    } catch (e) {
      debugPrint('[NotifService] timezone detection error: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  // ── Instant test ──────────────────────────────────────────────────────────

  /// Fire a notification right now — for debugging.
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Daily medicine reminder notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      99999,
      'Test Notification',
      'If you see this, notifications work!',
      details,
    );
    debugPrint('[NotifService] test notification fired');
  }

  // ── Schedule ──────────────────────────────────────────────────────────────

  Future<void> scheduleMedicine(Medicine medicine) async {
    if (!medicine.isActive) return;

    for (int i = 0; i < medicine.times.length; i++) {
      final parts = medicine.times[i].split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final notifId = _notificationId(medicine.id, i);

      debugPrint(
          '[NotifService] scheduling ${medicine.name} at $hour:$minute (id=$notifId)');

      await _scheduleDailyNotification(
        id: notifId,
        title: 'Time for ${medicine.name}',
        body: medicine.dosage != null && medicine.dosage!.isNotEmpty
            ? '${medicine.dosage} — tap to open'
            : 'Tap to open WiseBlood',
        hour: hour,
        minute: minute,
        payload: 'medicine_${medicine.id}',
      );
    }
  }

  Future<void> cancelMedicine(int medicineId, int timeCount) async {
    for (int i = 0; i < timeCount; i++) {
      await _plugin.cancel(_notificationId(medicineId, i));
    }
    for (int i = timeCount; i < timeCount + 5; i++) {
      await _plugin.cancel(_notificationId(medicineId, i));
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Private helpers ───────────────────────────────────────────────────────

  int _notificationId(int medicineId, int timeIndex) {
    return (medicineId * 100) + timeIndex;
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    debugPrint(
        '[NotifService] now=$now, scheduled=$scheduled (tz=${tz.local.name})');

    const androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Daily medicine reminder notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
}
