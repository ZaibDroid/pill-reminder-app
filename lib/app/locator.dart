import 'package:get_it/get_it.dart';
import '../core/services/database_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/local_storage_service.dart';
import '../core/services/permission_service.dart';
import '../core/services/alarm_service.dart';
import '../core/repositories/medicine_repository.dart';
import '../core/repositories/reminder_repository.dart';
import '../core/repositories/dose_log_repository.dart';
import '../core/repositories/emergency_contact_repository.dart';
import '../core/repositories/user_settings_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => LocalStorageService());
  locator.registerLazySingleton(() => PermissionService());
  locator.registerLazySingleton(() => AlarmService());
  locator.registerLazySingleton(() => MedicineRepository());
  locator.registerLazySingleton(() => ReminderRepository());
  locator.registerLazySingleton(() => DoseLogRepository());
  locator.registerLazySingleton(() => EmergencyContactRepository());
  locator.registerLazySingleton(() => UserSettingsRepository());
}
