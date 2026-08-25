import 'package:isar/isar.dart';
import '../../app/locator.dart';
import '../models/dose_log.dart';
import '../models/medicine.dart';
import '../services/database_service.dart';
import '../utils/custom_logger.dart';

class DoseLogRepository {
  final log = CustomLogger(className: '@DoseLogRepository');
  final DatabaseService _databaseService;

  DoseLogRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? locator<DatabaseService>();

  Isar get _isar => _databaseService.isar;

  /// Creates and saves a [DoseLog] entity with its linked [Medicine] and [ReminderTime].
  Future<Id> saveDoseLog(DoseLog doseLog) async {
    try {
      log.d('@saveDoseLog: Saving dose log for scheduled time ${doseLog.scheduledDateTime}');
      return await _isar.writeTxn(() async {
        final id = await _isar.doseLogs.put(doseLog);
        await doseLog.medicine.save();
        await doseLog.reminderTime.save();
        return id;
      });
    } catch (e, stackTrace) {
      log.e('@saveDoseLog: Error saving dose log', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves a [DoseLog] entity by its [id].
  Future<DoseLog?> getDoseLog(Id id) async {
    try {
      log.d('@getDoseLog: Fetching dose log with id $id');
      return await _isar.doseLogs.get(id);
    } catch (e, stackTrace) {
      log.e('@getDoseLog: Error getting dose log $id', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves all [DoseLog] entities from the database.
  Future<List<DoseLog>> getAllDoseLogs() async {
    try {
      log.d('@getAllDoseLogs: Fetching all dose logs');
      return await _isar.doseLogs.where().findAll();
    } catch (e, stackTrace) {
      log.e('@getAllDoseLogs: Error getting all dose logs', e, stackTrace);
      rethrow;
    }
  }

  /// Updates an existing [DoseLog] entity and its relationships.
  Future<Id> updateDoseLog(DoseLog doseLog) async {
    try {
      log.d('@updateDoseLog: Updating dose log with id ${doseLog.id}');
      return await _isar.writeTxn(() async {
        final id = await _isar.doseLogs.put(doseLog);
        await doseLog.medicine.save();
        await doseLog.reminderTime.save();
        return id;
      });
    } catch (e, stackTrace) {
      log.e('@updateDoseLog: Error updating dose log ${doseLog.id}', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes a [DoseLog] entity by its [id].
  Future<bool> deleteDoseLog(Id id) async {
    try {
      log.d('@deleteDoseLog: Deleting dose log with id $id');
      return await _isar.writeTxn(() async {
        return await _isar.doseLogs.delete(id);
      });
    } catch (e, stackTrace) {
      log.e('@deleteDoseLog: Error deleting dose log $id', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves dose logs scheduled within a specific date range [start] to [end] inclusive.
  /// Utilizes the indexed [scheduledDateTime] for optimal query performance.
  Future<List<DoseLog>> getDoseLogsForDateRange(DateTime start, DateTime end) async {
    try {
      log.d('@getDoseLogsForDateRange: Fetching dose logs between $start and $end');
      return await _isar.doseLogs
          .where()
          .scheduledDateTimeBetween(start, end)
          .findAll();
    } catch (e, stackTrace) {
      log.e('@getDoseLogsForDateRange: Error fetching dose logs for date range', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves all dose logs associated with a specific [medicineId].
  Future<List<DoseLog>> getDoseLogsForMedicine(Id medicineId) async {
    try {
      log.d('@getDoseLogsForMedicine: Fetching dose logs for medicine $medicineId');
      return await _isar.doseLogs
          .filter()
          .medicine((q) => q.idEqualTo(medicineId))
          .findAll();
    } catch (e, stackTrace) {
      log.e('@getDoseLogsForMedicine: Error fetching dose logs for medicine $medicineId', e, stackTrace);
      rethrow;
    }
  }
}
