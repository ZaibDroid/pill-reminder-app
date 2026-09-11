import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../utils/custom_logger.dart';

/// Helper for timezone database initialization and time scheduling calculations.
class NotificationTimezoneHelper {
  static final _log = CustomLogger(className: '@NotificationTimezoneHelper');

  /// Initializes timezone database and configures native device timezone location.
  static Future<void> configureTimezone() async {
    try {
      tz.initializeTimeZones();
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final timeZoneName = timeZoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      _log.i('@configureTimezone: Native timezone set to $timeZoneName');
    } catch (e) {
      _log.w('@configureTimezone: Error detecting timezone ($e), attempting fallback');
      try {
        final fallbackName = DateTime.now().timeZoneName;
        if (tz.timeZoneDatabase.locations.containsKey(fallbackName)) {
          tz.setLocalLocation(tz.getLocation(fallbackName));
        }
      } catch (_) {}
    }
  }

  /// Calculates the next [tz.TZDateTime] occurrence for a given [hour] and [minute].
  static tz.TZDateTime nextInstanceOfTime(int hour, int minute) {
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

  /// Builds platform-specific initialization settings.
  static InitializationSettings buildInitializationSettings() {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open');

    return const InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );
  }
}
