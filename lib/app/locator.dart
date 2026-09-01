import 'package:get_it/get_it.dart';
import '../core/models/medicine.dart';
import '../core/repositories/dose_log_repository.dart';
import '../core/repositories/emergency_contact_repository.dart';
import '../core/repositories/medicine_repository.dart';
import '../core/repositories/reminder_repository.dart';
import '../core/repositories/user_settings_repository.dart';
import '../core/services/alarm_service.dart';
import '../core/services/database_service.dart';
import '../core/services/local_storage_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/permission_service.dart';
import '../ui/viewmodels/alarm_viewmodel.dart';
import '../ui/viewmodels/app_lock_viewmodel.dart';
import '../ui/viewmodels/add_medicine_viewmodel.dart';
import '../ui/viewmodels/emergency_viewmodel.dart';
import '../ui/viewmodels/history_viewmodel.dart';
import '../ui/viewmodels/home_viewmodel.dart';
import '../ui/viewmodels/medicine_viewmodel.dart';
import '../ui/viewmodels/reports_viewmodel.dart';
import '../ui/viewmodels/settings_viewmodel.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Services
  locator.registerLazySingleton(() => DatabaseService());
  locator.registerLazySingleton(() => NotificationService());
  locator.registerLazySingleton(() => LocalStorageService());
  locator.registerLazySingleton(() => PermissionService());
  locator.registerLazySingleton(() => AlarmService());

  // Repositories
  locator.registerLazySingleton(() => MedicineRepository());
  locator.registerLazySingleton(() => ReminderRepository());
  locator.registerLazySingleton(() => DoseLogRepository());
  locator.registerLazySingleton(() => EmergencyContactRepository());
  locator.registerLazySingleton(() => UserSettingsRepository());

  // ViewModels
  locator.registerFactory(() => HomeViewModel());
  locator.registerFactory(() => MedicineViewModel());
  locator.registerFactoryParam<AddMedicineViewModel, Medicine?, void>(
    (med, _) => AddMedicineViewModel(existingMedicine: med),
  );
  locator.registerFactory(() => HistoryViewModel());
  locator.registerFactory(() => ReportsViewModel());
  locator.registerFactory(() => EmergencyViewModel());
  locator.registerFactory(() => SettingsViewModel());
  locator.registerFactory(() => AppLockViewModel());
  locator.registerFactory(() => AlarmViewModel());
}
