import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../app/locator.dart';
import '../models/medicine.dart';
import '../repositories/medicine_repository.dart';
import '../utils/custom_logger.dart';
import 'notifications/notification_action_handler.dart';
import 'notifications/notification_channels.dart';
import 'notifications/notification_timezone_helper.dart';
import 'permission_service.dart';

/// Offline-first notification service for MediAlert medication reminders.
/// Coordinates notification initialization, scheduling, cancellation, and inventory alerts.
class NotificationService {
  final log = CustomLogger(className: '@NotificationService');

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final PermissionService _permissionService;

  bool _isInitialized = false;

  /// High-priority notification channel ID for medication reminders.
  static const String channelId = NotificationChannels.reminderChannelId;
  static const String channelName = NotificationChannels.reminderChannelName;
  static const String channelDescription = NotificationChannels.reminderChannelDescription;

  /// Standard notification channel ID for low-stock inventory refill alerts.
  static const String lowStockChannelId = NotificationChannels.lowStockChannelId;
  static const String lowStockChannelName = NotificationChannels.lowStockChannelName;
  static const String lowStockChannelDescription = NotificationChannels.lowStockChannelDescription;

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

      // 1. Initialize timezone
      await NotificationTimezoneHelper.configureTimezone();

      // 2. Initialize notification plugin
      final initializationSettings = NotificationTimezoneHelper.buildInitializationSettings();
      final initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          NotificationActionHandler.handleResponse(
            response,
            onNotificationTap: onNotificationTap,
            onLowStockCheck: checkAndNotifyLowStock,
          );
        },
      );

      // 3. Create native notification channels on Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        await NotificationChannels.createAndroidChannels(_notificationsPlugin);
      }

      _isInitialized = initialized ?? true;
      log.i('@init: NotificationService initialized successfully (status: $_isInitialized)');

      // 4. Check if app was launched via notification tap
      await _checkAppLaunchNotification(onNotificationTap);

      // 5. Optionally request permissions
      if (requestPermission) {
        log.i('@init: Requesting notification permissions...');
        await _permissionService.requestNotificationPermission();
      }

      return _isInitialized;
    } catch (e, stackTrace) {
      log.e('@init: Failed to initialize NotificationService', e, stackTrace);
      return false;
    }
  }

  /// Displays an immediate local notification (e.g. medication alarm).
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool enableVibration = true,
  }) async {
    try {
      log.i('@showNotification: Showing notification [ID: $id] "$title"');
      await _notificationsPlugin.show(
        id,
        title,
        body,
        NotificationChannels.buildReminderDetails(enableVibration: enableVibration),
        payload: payload,
      );
      log.d('@showNotification: Notification [ID: $id] displayed successfully');
    } catch (e, stackTrace) {
      log.e('@showNotification: Failed to show notification [ID: $id]', e, stackTrace);
    }
  }

  /// Displays an immediate low-stock alert notification (non-alarm).
  /// Mentions the medicine name and current remaining stock quantity.
  Future<void> showLowStockNotification({
    required Medicine medicine,
    bool enableVibration = true,
  }) async {
    try {
      final stock = medicine.currentStock;
      final unitStr = medicine.formFactor.isNotEmpty ? medicine.formFactor : 'dose';
      final plural = stock == 1 ? unitStr : '${unitStr}s';

      final title = 'Low Stock Alert: ${medicine.name}';
      final body = stock <= 0
          ? '${medicine.name} is out of stock (0 $plural left). Please refill your prescription.'
          : '${medicine.name} is running low: only $stock $plural remaining. Please refill soon.';

      final payload = jsonEncode({
        'type': 'low_stock_alert',
        'medicineId': medicine.id,
      });

      final notificationId = 500000 + medicine.id;
      log.i('@showLowStockNotification: Showing alert for "${medicine.name}" ($stock $plural) [ID: $notificationId]');

      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        NotificationChannels.buildLowStockDetails(enableVibration: enableVibration),
        payload: payload,
      );
      log.d('@showLowStockNotification: Low stock alert displayed for "${medicine.name}"');
    } catch (e, stackTrace) {
      log.e('@showLowStockNotification: Failed to show low stock alert for "${medicine.name}"', e, stackTrace);
    }
  }

  /// Checks if medicine stock is at or below threshold and triggers notification if enabled.
  Future<void> checkAndNotifyLowStock(Medicine medicine) async {
    try {
      if (medicine.isRefillAlertEnabled && medicine.currentStock <= medicine.lowStockThreshold) {
        log.i('@checkAndNotifyLowStock: "${medicine.name}" stock (${medicine.currentStock}) <= threshold (${medicine.lowStockThreshold}). Triggering alert.');
        await showLowStockNotification(medicine: medicine);
      }
    } catch (e, stackTrace) {
      log.e('@checkAndNotifyLowStock: Error checking low stock for "${medicine.name}"', e, stackTrace);
    }
  }

  /// Checks all registered medicines and sends low-stock alerts for those at or below threshold.
  Future<int> checkAllMedicinesForLowStock({MedicineRepository? medicineRepository}) async {
    try {
      final repo = medicineRepository ??
          (locator.isRegistered<MedicineRepository>() ? locator<MedicineRepository>() : null);
      if (repo == null) return 0;

      final medicines = await repo.getAllMedicines();
      int count = 0;
      for (final med in medicines) {
        if (med.isRefillAlertEnabled && med.currentStock <= med.lowStockThreshold) {
          await showLowStockNotification(medicine: med);
          count++;
        }
      }
      log.i('@checkAllMedicinesForLowStock: Checked ${medicines.length} medicines, sent $count alert(s)');
      return count;
    } catch (e, stackTrace) {
      log.e('@checkAllMedicinesForLowStock: Error checking medicines for low stock', e, stackTrace);
      return 0;
    }
  }

  /// Schedules a one-time notification at an exact [scheduledDate].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool enableVibration = true,
  }) async {
    try {
      log.i('@scheduleNotification: Scheduling [ID: $id] "$title" at $scheduledDate');
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
        log.w('@scheduleNotification: Time $scheduledDate is in the past. Skipping schedule.');
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        NotificationChannels.buildReminderDetails(enableVibration: enableVibration),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      log.i('@scheduleNotification: Successfully scheduled [ID: $id] for $tzDateTime');
    } catch (e, stackTrace) {
      log.e('@scheduleNotification: Failed to schedule [ID: $id]', e, stackTrace);
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
      log.i('@scheduleDailyNotification: Scheduling daily [ID: $id] "$title" at $hour:${minute.toString().padLeft(2, '0')}');
      final scheduledTZDateTime = NotificationTimezoneHelper.nextInstanceOfTime(hour, minute);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDateTime,
        NotificationChannels.buildReminderDetails(enableVibration: enableVibration),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      log.i('@scheduleDailyNotification: Scheduled daily [ID: $id] starting at $scheduledTZDateTime');
    } catch (e, stackTrace) {
      log.e('@scheduleDailyNotification: Failed to schedule daily [ID: $id]', e, stackTrace);
    }
  }

  /// Cancels a specific scheduled or active notification by [id].
  Future<void> cancelNotification(int id) async {
    try {
      log.i('@cancelNotification: Cancelling [ID: $id]');
      await _notificationsPlugin.cancel(id);
      log.d('@cancelNotification: Notification [ID: $id] cancelled successfully');
    } catch (e, stackTrace) {
      log.e('@cancelNotification: Failed to cancel [ID: $id]', e, stackTrace);
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
      final active = await _notificationsPlugin.getActiveNotifications();
      log.d('@getActiveNotifications: Found ${active.length} active notification(s)');
      return active;
    } catch (e, stackTrace) {
      log.e('@getActiveNotifications: Failed to fetch active notifications', e, stackTrace);
      return [];
    }
  }

  /// Checks if app was launched via notification tap on cold boot.
  Future<void> _checkAppLaunchNotification(
    void Function(NotificationResponse)? onNotificationTap,
  ) async {
    try {
      final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true &&
          launchDetails?.notificationResponse != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          NotificationActionHandler.handleResponse(
            launchDetails!.notificationResponse!,
            onNotificationTap: onNotificationTap,
            onLowStockCheck: checkAndNotifyLowStock,
          );
        });
      }
    } catch (_) {}
  }
}
