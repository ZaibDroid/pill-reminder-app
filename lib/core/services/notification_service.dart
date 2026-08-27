import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../app/locator.dart';
import '../utils/custom_logger.dart';
import 'permission_service.dart';

/// Offline-first notification service for MediAlert medication reminders.
/// Handles local notification initialization, scheduling, cancellation, and permission checks.
class NotificationService {
  final log = CustomLogger(className: '@NotificationService');

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final PermissionService _permissionService;

  bool _isInitialized = false;

  /// High-priority notification channel ID for medication reminders.
  static const String channelId = 'medialert_reminders';
  static const String channelName = 'Medication Reminders';
  static const String channelDescription =
      'Notifications for scheduled medication doses and adherence reminders';

  NotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
    PermissionService? permissionService,
  })  : _notificationsPlugin =
            notificationsPlugin ?? FlutterLocalNotificationsPlugin(),
        _permissionService = permissionService ??
            (locator.isRegistered<PermissionService>()
                ? locator<PermissionService>()
                : PermissionService());

  /// Returns true if the notification service is initialized.
  bool get isInitialized => _isInitialized;

  /// Exposes the underlying notification plugin instance.
  FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

  /// Exposes the permission service instance used by this notification service.
  PermissionService get permissionService => _permissionService;

  /// Initializes the local notification plugin, timezone database, and notification channels.
  /// Optionally requests notification permissions via [PermissionService].
  Future<bool> init({
    bool requestPermission = false,
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_isInitialized) {
      log.d('@init: NotificationService is already initialized');
      return true;
    }

    try {
      log.i('@init: Initializing offline-first NotificationService...');

      // 1. Initialize timezone database
      try {
        tz.initializeTimeZones();
      } catch (e) {
        log.w('@init: Timezones already initialized or error initializing: $e');
      }

      // 2. Setup Android initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. Setup iOS/macOS (Darwin) initialization settings
      // We manage permissions explicitly via PermissionService
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // 4. Setup Linux initialization settings
      const linuxSettings =
          LinuxInitializationSettings(defaultActionName: 'Open');

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
      );

      // 5. Initialize the plugin
      final initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
      );

      // 6. Create Android Notification Channel
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _createAndroidNotificationChannel();
      }

      _isInitialized = initialized ?? true;
      log.i('@init: NotificationService initialized successfully (status: $_isInitialized)');

      // 7. Optionally handle permission request
      if (requestPermission) {
        log.i('@init: Requesting notification permissions as requested...');
        await _permissionService.requestNotificationPermission();
      }

      return _isInitialized;
    } catch (e, stackTrace) {
      log.e('@init: Failed to initialize NotificationService', e, stackTrace);
      return false;
    }
  }

  /// Creates the primary high-importance Android notification channel.
  Future<void> _createAndroidNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        log.d('@_createAndroidNotificationChannel: Notification channel created ($channelId)');
      }
    } catch (e, stackTrace) {
      log.e('@_createAndroidNotificationChannel: Error creating Android channel', e, stackTrace);
    }
  }

  /// Returns the default [NotificationDetails] for medication reminders.
  NotificationDetails _defaultNotificationDetails({
    bool enableVibration = true,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: enableVibration,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  /// Displays an immediate local notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool enableVibration = true,
  }) async {
    try {
      log.i('@showNotification: Showing immediate notification [ID: $id] "$title"');
      await _notificationsPlugin.show(
        id,
        title,
        body,
        _defaultNotificationDetails(enableVibration: enableVibration),
        payload: payload,
      );
      log.d('@showNotification: Notification [ID: $id] displayed successfully');
    } catch (e, stackTrace) {
      log.e('@showNotification: Failed to show notification [ID: $id]', e, stackTrace);
    }
  }

  /// Schedules a one-time notification at an exact [scheduledDate].
  /// Uses timezone-aware scheduling with [AndroidScheduleMode.exactAllowWhileIdle].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool enableVibration = true,
  }) async {
    try {
      log.i(
        '@scheduleNotification: Scheduling notification [ID: $id] "$title" at $scheduledDate',
      );

      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
        log.w(
          '@scheduleNotification: Scheduled time $scheduledDate is in the past. Skipping schedule.',
        );
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        _defaultNotificationDetails(enableVibration: enableVibration),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      log.i(
        '@scheduleNotification: Successfully scheduled notification [ID: $id] for $tzDateTime',
      );
    } catch (e, stackTrace) {
      log.e('@scheduleNotification: Failed to schedule notification [ID: $id]', e, stackTrace);
    }
  }

  /// Schedules a repeating daily notification at a specified [hour] and [minute].
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    bool enableVibration = true,
  }) async {
    try {
      log.i(
        '@scheduleDailyNotification: Scheduling daily notification [ID: $id] "$title" at $hour:${minute.toString().padLeft(2, '0')}',
      );

      final scheduledTZDateTime = _nextInstanceOfTime(hour, minute);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDateTime,
        _defaultNotificationDetails(enableVibration: enableVibration),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );

      log.i(
        '@scheduleDailyNotification: Successfully scheduled daily notification [ID: $id] starting at $scheduledTZDateTime',
      );
    } catch (e, stackTrace) {
      log.e(
        '@scheduleDailyNotification: Failed to schedule daily notification [ID: $id]',
        e,
        stackTrace,
      );
    }
  }

  /// Helper to compute the next [tz.TZDateTime] for a given [hour] and [minute].
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Cancels a specific scheduled or active notification by [id].
  Future<void> cancelNotification(int id) async {
    try {
      log.i('@cancelNotification: Cancelling notification [ID: $id]');
      await _notificationsPlugin.cancel(id);
      log.d('@cancelNotification: Notification [ID: $id] cancelled successfully');
    } catch (e, stackTrace) {
      log.e('@cancelNotification: Failed to cancel notification [ID: $id]', e, stackTrace);
    }
  }

  /// Cancels all scheduled and active notifications.
  Future<void> cancelAllNotifications() async {
    try {
      log.i('@cancelAllNotifications: Cancelling all notifications...');
      await _notificationsPlugin.cancelAll();
      log.i('@cancelAllNotifications: All notifications cancelled successfully');
    } catch (e, stackTrace) {
      log.e('@cancelAllNotifications: Failed to cancel all notifications', e, stackTrace);
    }
  }

  /// Retrieves a list of all currently pending notification requests.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      log.d('@getPendingNotifications: Fetching pending notifications...');
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      log.d('@getPendingNotifications: Found ${pending.length} pending notification(s)');
      return pending;
    } catch (e, stackTrace) {
      log.e('@getPendingNotifications: Failed to fetch pending notifications', e, stackTrace);
      return [];
    }
  }

  /// Retrieves a list of all currently active notifications shown in the status bar.
  Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      log.d('@getActiveNotifications: Fetching active notifications...');
      final active = await _notificationsPlugin.getActiveNotifications();
      log.d('@getActiveNotifications: Found ${active.length} active notification(s)');
      return active;
    } catch (e, stackTrace) {
      log.e('@getActiveNotifications: Failed to fetch active notifications', e, stackTrace);
      return [];
    }
  }
}
