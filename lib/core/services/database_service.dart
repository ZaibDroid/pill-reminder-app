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

  Isar get isar {
    if (_isar == null || !_isar!.isOpen) {
      log.e('@isar: Database accessed before initialization');
      throw StateError('Isar database is not initialized. Call init() first.');
    }
    return _isar!;
  }

  bool get isOpen => _isar != null && _isar!.isOpen;

  Future<void> init() async {
    if (_isar != null && _isar!.isOpen) {
      log.d('@init: Isar database is already open');
      return;
    }

    try {
      log.i('@init: Initializing offline-first local Isar database...');
      final dir = await getApplicationDocumentsDirectory();

      _isar = await Isar.open(
        [
          MedicineSchema,
          ReminderTimeSchema,
          DoseLogSchema,
          EmergencyContactSchema,
          UserSettingsSchema,
        ],
        directory: dir.path,
        name: 'medialert_db',
        inspector: true,
      );

      log.i('@init: Isar database initialized successfully at: ${dir.path}');
    } catch (e, stackTrace) {
      log.e('@init: Failed to initialize Isar database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      log.i('@close: Closing Isar database');
      await _isar!.close();
      _isar = null;
    }
  }
}
