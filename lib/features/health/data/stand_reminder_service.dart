import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../medicine/data/notification_service.dart';

const _channelId = 'stand_reminder';
const _channelName = 'Stand & Move';
const _channelDesc = 'Periodic reminders to stand up and walk';
const _baseNotifId = 80000;

class StandReminderService {
  StandReminderService._();
  static final StandReminderService instance = StandReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final _titles = [
    'Time to stand up!',
    'Move your body!',
    'Take a quick break',
    'Stretch & walk',
    'Your body needs a break',
    'Stand up & breathe',
  ];

  final _bodies = [
    'You\'ve been sitting for a while. Walk around for 2 minutes.',
    'A short walk boosts focus and energy. Get moving!',
    'Stand up, stretch, and take a few steps.',
    'Sitting too long is harmful. Time for a mini walk!',
    'Your back will thank you. Stand up and move.',
    'Quick break time — walk, stretch, reset.',
  ];

  Future<void> startReminders({required int intervalMinutes}) async {
    await NotificationService.instance.init();
    await cancelReminders();

    final now = tz.TZDateTime.now(tz.local);
    final count = (16 * 60) ~/ intervalMinutes;
    final capped = count.clamp(1, 48);

    for (int i = 0; i < capped; i++) {
      final fireAt = now.add(Duration(minutes: intervalMinutes * (i + 1)));
      final titleIdx = i % _titles.length;
      final bodyIdx = i % _bodies.length;

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
      );

      await _plugin.zonedSchedule(
        _baseNotifId + i,
        _titles[titleIdx],
        _bodies[bodyIdx],
        fireAt,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'stand_reminder_$i',
      );
    }

    debugPrint(
        '[StandReminder] scheduled $capped notifications every ${intervalMinutes}min');
  }

  Future<void> cancelReminders() async {
    for (int i = 0; i < 48; i++) {
      await _plugin.cancel(_baseNotifId + i);
    }
    debugPrint('[StandReminder] cancelled all');
  }
}
