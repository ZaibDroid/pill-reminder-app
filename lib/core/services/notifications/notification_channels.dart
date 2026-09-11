import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../utils/custom_logger.dart';

/// Manages notification channel configuration and [NotificationDetails] building.
class NotificationChannels {
  static final _log = CustomLogger(className: '@NotificationChannels');

  // Channel IDs and constants
  static const String reminderChannelId = 'medialert_reminders';
  static const String reminderChannelName = 'Medication Reminders';
  static const String reminderChannelDescription =
      'Notifications for scheduled medication doses and adherence reminders';

  static const String lowStockChannelId = 'medialert_low_stock';
  static const String lowStockChannelName = 'Low Stock & Refill Alerts';
  static const String lowStockChannelDescription =
      'Notifications when medication stock is running low';

  /// Registers native Android notification channels.
  static Future<void> createAndroidChannels(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    try {
      final androidPlugin = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // 1. High-importance alarm channel for dose reminders
        final reminderChannel = AndroidNotificationChannel(
          reminderChannelId,
          reminderChannelName,
          description: reminderChannelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );

        // 2. Standard notification channel for low-stock inventory alerts (not an alarm)
        const lowStockChannel = AndroidNotificationChannel(
          lowStockChannelId,
          lowStockChannelName,
          description: lowStockChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        await androidPlugin.createNotificationChannel(reminderChannel);
        await androidPlugin.createNotificationChannel(lowStockChannel);
        _log.d('@createAndroidChannels: Channels created ($reminderChannelId, $lowStockChannelId)');
      }
    } catch (e, stackTrace) {
      _log.e('@createAndroidChannels: Error creating channels', e, stackTrace);
    }
  }

  /// Builds [NotificationDetails] for scheduled medication dose reminders with action buttons.
  static NotificationDetails buildReminderDetails({
    bool enableVibration = true,
  }) {
    final androidDetails = AndroidNotificationDetails(
      reminderChannelId,
      reminderChannelName,
      channelDescription: reminderChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: enableVibration,
      vibrationPattern: enableVibration
          ? Int64List.fromList([0, 1000, 500, 1000])
          : null,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: const Color(0xFF00685F),
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'take_action',
          'Take',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'snooze_action',
          'Snooze (10m)',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'skip_action',
          'Skip',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  /// Builds [NotificationDetails] for low-stock inventory alerts (non-alarm notification).
  static NotificationDetails buildLowStockDetails({
    bool enableVibration = true,
  }) {
    final androidDetails = AndroidNotificationDetails(
      lowStockChannelId,
      lowStockChannelName,
      channelDescription: lowStockChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: enableVibration,
      category: AndroidNotificationCategory.reminder,
      fullScreenIntent: false,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: const Color(0xFFBA1A1A),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }
}
