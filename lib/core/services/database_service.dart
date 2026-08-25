import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/medicine.dart';
import '../models/reminder_time.dart';
import '../models/dose_log.dart';
import '../models/emergency_contact.dart';
import '../models/user_settings.dart';
import '../utils/custom_logger.dart';

class DatabaseService {
  final log = CustomLogger(className: '@DatabaseService');

  Isar? _isar;

  /// Exposes the active [Isar] database instance.
  /// Throws [StateError] if accessed before initialization.
  Isar get isar {
    if (_isar == null || !_isar!.isOpen) {
      log.e('@isar: Database accessed before initialization');
      throw StateError('Isar database is not initialized. Call init() first.');
    }
    return _isar!;
  }

  /// Returns true if the database instance is open and ready.
  bool get isOpen => _isar != null && _isar!.isOpen;

  /// Initializes and opens the offline-first local Isar database.
  Future<void> init({
    String? directory,
    String name = 'medialert_db',
    bool inspector = true,
  }) async {
    if (_isar != null && _isar!.isOpen) {
      log.d('@init: Isar database is already open');
      return;
    }

    final existingInstance = Isar.getInstance(name);
    if (existingInstance != null && existingInstance.isOpen) {
      _isar = existingInstance;
      log.d('@init: Reusing existing open Isar database instance');
      return;
    }

    try {
      log.i('@init: Initializing offline-first local Isar database...');
      final path = directory ?? (await getApplicationDocumentsDirectory()).path;

      _isar = await Isar.open(
        [
          MedicineSchema,
          ReminderTimeSchema,
          DoseLogSchema,
          EmergencyContactSchema,
          UserSettingsSchema,
        ],
        directory: path,
        name: name,
        inspector: inspector,
      );

      log.i('@init: Isar database initialized successfully at: $path');
    } catch (e, stackTrace) {
      log.e('@init: Failed to initialize Isar database', e, stackTrace);
      rethrow;
    }
  }

  /// Closes the Isar database connection, optionally deleting the database files.
  Future<void> close({bool deleteFromDisk = false}) async {
    if (_isar != null && _isar!.isOpen) {
      log.i('@close: Closing Isar database (deleteFromDisk: $deleteFromDisk)');
      await _isar!.close(deleteFromDisk: deleteFromDisk);
      _isar = null;
    }
  }
}
