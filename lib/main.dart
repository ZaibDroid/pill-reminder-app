import 'package:flutter/material.dart';
import 'app/locator.dart';
import 'app/app.dart';
import 'core/services/database_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  // Initialize offline-first core services
  await locator<DatabaseService>().init();
  await locator<LocalStorageService>().init();
  await locator<NotificationService>().init();

  runApp(const PillReminderApp());
}
