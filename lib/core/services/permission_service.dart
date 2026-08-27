import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../utils/custom_logger.dart';

/// Service responsible for managing app runtime permissions.
/// Specifically handles notification and exact alarm permissions
/// required for MediAlert's offline-first medication reminder engine.
class PermissionService {
  final log = CustomLogger(className: '@PermissionService');

  /// Indicates whether the current platform is Android.
  @visibleForTesting
  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// Checks the current status of the notification permission.
  Future<ph.PermissionStatus> checkNotificationPermission() async {
    try {
      log.d('@checkNotificationPermission: Checking notification permission status...');
      final status = await ph.Permission.notification.status;
      log.d('@checkNotificationPermission: Current notification status: $status');
      return status;
    } catch (e, stackTrace) {
      log.e('@checkNotificationPermission: Error checking notification permission', e, stackTrace);
      return ph.PermissionStatus.denied;
    }
  }

  /// Returns true if notification permission is granted or limited (iOS provisional).
  Future<bool> isNotificationPermissionGranted() async {
    try {
      final status = await checkNotificationPermission();
      final isGranted = status.isGranted || status.isLimited;
      log.d('@isNotificationPermissionGranted: Notification permission granted: $isGranted');
      return isGranted;
    } catch (e, stackTrace) {
      log.e('@isNotificationPermissionGranted: Error checking if notification is granted', e, stackTrace);
      return false;
    }
  }

  /// Requests notification permission from the user.
  Future<ph.PermissionStatus> requestNotificationPermission() async {
    try {
      log.i('@requestNotificationPermission: Requesting notification permission...');
      final status = await ph.Permission.notification.request();
      log.i('@requestNotificationPermission: Notification permission result: $status');
      return status;
    } catch (e, stackTrace) {
      log.e('@requestNotificationPermission: Error requesting notification permission', e, stackTrace);
      return ph.PermissionStatus.denied;
    }
  }

  /// Checks the current status of the exact alarm permission.
  /// Exact alarms (`SCHEDULE_EXACT_ALARM`) are required on Android 12+ (API 31+).
  /// On other platforms (e.g., iOS), exact alarm permissions are not applicable and return [ph.PermissionStatus.granted].
  Future<ph.PermissionStatus> checkExactAlarmPermission() async {
    if (!isAndroid) {
      log.d('@checkExactAlarmPermission: Non-Android platform, exact alarm permission is implicitly granted');
      return ph.PermissionStatus.granted;
    }

    try {
      log.d('@checkExactAlarmPermission: Checking exact alarm permission status on Android...');
      final status = await ph.Permission.scheduleExactAlarm.status;
      log.d('@checkExactAlarmPermission: Current exact alarm status: $status');
      return status;
    } catch (e, stackTrace) {
      log.e('@checkExactAlarmPermission: Error checking exact alarm permission', e, stackTrace);
      return ph.PermissionStatus.denied;
    }
  }

  /// Returns true if exact alarm permission is granted.
  /// Always returns true on non-Android platforms.
  Future<bool> isExactAlarmPermissionGranted() async {
    if (!isAndroid) {
      return true;
    }

    try {
      final status = await checkExactAlarmPermission();
      final isGranted = status.isGranted;
      log.d('@isExactAlarmPermissionGranted: Exact alarm permission granted: $isGranted');
      return isGranted;
    } catch (e, stackTrace) {
      log.e('@isExactAlarmPermissionGranted: Error checking if exact alarm is granted', e, stackTrace);
      return false;
    }
  }

  /// Requests exact alarm permission from the user on Android.
  /// On other platforms, returns [ph.PermissionStatus.granted] immediately.
  Future<ph.PermissionStatus> requestExactAlarmPermission() async {
    if (!isAndroid) {
      log.d('@requestExactAlarmPermission: Non-Android platform, skipping exact alarm request');
      return ph.PermissionStatus.granted;
    }

    try {
      log.i('@requestExactAlarmPermission: Requesting exact alarm permission on Android...');
      final status = await ph.Permission.scheduleExactAlarm.request();
      log.i('@requestExactAlarmPermission: Exact alarm permission result: $status');
      return status;
    } catch (e, stackTrace) {
      log.e('@requestExactAlarmPermission: Error requesting exact alarm permission', e, stackTrace);
      return ph.PermissionStatus.denied;
    }
  }

  /// Checks if all permissions required for MediAlert alarms and notifications are granted.
  /// On Android: Requires Notification and ScheduleExactAlarm permissions.
  /// On iOS / other platforms: Requires Notification permission.
  Future<bool> hasAllRequiredPermissions() async {
    try {
      log.d('@hasAllRequiredPermissions: Evaluating all required permissions...');
      final notificationGranted = await isNotificationPermissionGranted();
      final exactAlarmGranted = await isExactAlarmPermissionGranted();

      final allGranted = notificationGranted && exactAlarmGranted;
      log.i(
        '@hasAllRequiredPermissions: Required permissions status -> '
        'Notification: $notificationGranted, ExactAlarm: $exactAlarmGranted, All: $allGranted',
      );
      return allGranted;
    } catch (e, stackTrace) {
      log.e('@hasAllRequiredPermissions: Error checking all required permissions', e, stackTrace);
      return false;
    }
  }

  /// Requests all permissions required by the PRD for notifications and alarms.
  /// Requests notification permission first, and on Android also requests exact alarm permission.
  /// Returns a map of requested permissions and their resulting statuses.
  Future<Map<ph.Permission, ph.PermissionStatus>> requestAllRequiredPermissions() async {
    final Map<ph.Permission, ph.PermissionStatus> results = {};

    try {
      log.i('@requestAllRequiredPermissions: Starting sequential permission request flow...');

      // 1. Notification Permission
      final notifStatus = await requestNotificationPermission();
      results[ph.Permission.notification] = notifStatus;

      // 2. Exact Alarm Permission (Android only)
      if (isAndroid) {
        final alarmStatus = await requestExactAlarmPermission();
        results[ph.Permission.scheduleExactAlarm] = alarmStatus;
      }

      log.i('@requestAllRequiredPermissions: Completed requesting required permissions: $results');
      return results;
    } catch (e, stackTrace) {
      log.e('@requestAllRequiredPermissions: Error requesting required permissions', e, stackTrace);
      return results;
    }
  }

  /// Opens the device settings screen for the app.
  /// Useful when permissions are permanently denied and must be toggled manually in settings.
  Future<bool> openAppSettings() async {
    try {
      log.i('@openAppSettings: Opening application settings screen...');
      final opened = await ph.openAppSettings();
      log.i('@openAppSettings: Open app settings result: $opened');
      return opened;
    } catch (e, stackTrace) {
      log.e('@openAppSettings: Error opening app settings', e, stackTrace);
      return false;
    }
  }
}
