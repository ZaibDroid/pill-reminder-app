import 'package:isar/isar.dart';
import '../../app/locator.dart';
import '../models/medicine.dart';
import '../models/reminder_time.dart';
import '../services/database_service.dart';
import '../utils/custom_logger.dart';

class MedicineRepository {
  final log = CustomLogger(className: '@MedicineRepository');
  final DatabaseService _databaseService;

  MedicineRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? locator<DatabaseService>();

  Isar get _isar => _databaseService.isar;

  /// Creates and saves a new [Medicine] entity with its reminder links.
  Future<Id> saveMedicine(Medicine medicine) async {
    try {
      log.d('@saveMedicine: Saving medicine "${medicine.name}"');
      medicine.updatedAt = DateTime.now();
      return await _isar.writeTxn(() async {
        final id = await _isar.medicines.put(medicine);
        await medicine.reminders.save();
        return id;
      });
    } catch (e, stackTrace) {
      log.e('@saveMedicine: Error saving medicine "${medicine.name}"', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves a [Medicine] entity by its [id].
  Future<Medicine?> getMedicine(Id id) async {
    try {
      log.d('@getMedicine: Fetching medicine with id $id');
      return await _isar.medicines.get(id);
    } catch (e, stackTrace) {
      log.e('@getMedicine: Error getting medicine $id', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves all [Medicine] entities from the database.
  Future<List<Medicine>> getAllMedicines() async {
    try {
      log.d('@getAllMedicines: Fetching all medicines');
      return await _isar.medicines.where().findAll();
    } catch (e, stackTrace) {
      log.e('@getAllMedicines: Error getting all medicines', e, stackTrace);
      rethrow;
    }
  }

  /// Updates an existing [Medicine] entity.
  Future<Id> updateMedicine(Medicine medicine) async {
    try {
      log.d('@updateMedicine: Updating medicine with id ${medicine.id}');
      medicine.updatedAt = DateTime.now();
      return await _isar.writeTxn(() async {
        final id = await _isar.medicines.put(medicine);
        await medicine.reminders.save();
        return id;
      });
    } catch (e, stackTrace) {
      log.e('@updateMedicine: Error updating medicine ${medicine.id}', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes a [Medicine] entity by its [id].
  /// Cascadely deletes all linked [ReminderTime] records in the same transaction,
  /// while preserving historical [DoseLog] records.
  Future<bool> deleteMedicine(Id id) async {
    try {
      log.d('@deleteMedicine: Deleting medicine with id $id and associated reminders');
      return await _isar.writeTxn(() async {
        final medicine = await _isar.medicines.get(id);
        if (medicine == null) {
          return false;
        }

        // Collect all linked reminder IDs from both the links collection and backlink queries
        await medicine.reminders.load();
        final reminderIds = medicine.reminders.map((r) => r.id).toSet();

        final queryReminders = await _isar.reminderTimes
            .filter()
            .medicine((q) => q.idEqualTo(id))
            .findAll();
        reminderIds.addAll(queryReminders.map((r) => r.id));

        // Delete all linked reminders
        if (reminderIds.isNotEmpty) {
          await _isar.reminderTimes.deleteAll(reminderIds.toList());
        }

        // Delete the medicine entity (DoseLog records are preserved)
        return await _isar.medicines.delete(id);
      });
    } catch (e, stackTrace) {
      log.e('@deleteMedicine: Error deleting medicine $id', e, stackTrace);
      rethrow;
    }
  }
}
