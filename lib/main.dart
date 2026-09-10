import 'package:flutter/material.dart';
import 'app/locator.dart';
import 'app/app.dart';
import 'core/services/alarm_service.dart';
import 'core/services/database_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  // Initialize offline-first core services
  await locator<DatabaseService>().init();
  await locator<LocalStorageService>().init();
  await locator<NotificationService>().init();

  // Ensure runtime permissions and sync all active medication alarms with correct native timezone
  try {
    final permissionService = locator<PermissionService>();
    final hasPerms = await permissionService.hasAllRequiredPermissions();
    if (!hasPerms) {
      await permissionService.requestAllRequiredPermissions();
    }
  } catch (_) {}

  try {
    await locator<AlarmService>().rescheduleAllActiveAlarms();
  } catch (_) {}

  runApp(const PillReminderApp());
}

