import 'package:get_it/get_it.dart';
import '../core/services/database_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/local_storage_service.dart';
import '../core/services/permission_service.dart';
import '../core/services/alarm_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => LocalStorageService());
  locator.registerLazySingleton(() => PermissionService());
  locator.registerLazySingleton(() => AlarmService());
}
