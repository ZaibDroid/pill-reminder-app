import 'package:isar/isar.dart';
import '../../app/locator.dart';
import '../models/reminder_time.dart';
import '../services/database_service.dart';
import '../utils/custom_logger.dart';

class ReminderRepository {
  final log = CustomLogger(className: '@ReminderRepository');
  final DatabaseService _databaseService;

  ReminderRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? locator<DatabaseService>();

  Isar get _isar => _databaseService.isar;

  /// Creates and saves a [ReminderTime] entity with its linked [Medicine].
  Future<Id> saveReminderTime(ReminderTime reminderTime) async {
    try {
      log.d(
        '@saveReminderTime: Saving reminder time (${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')})',
      );
      return await _isar.writeTxn(() async {
        final id = await _isar.reminderTimes.put(reminderTime);
        await reminderTime.medicine.save();
        return id;
      });
    } catch (e, stackTrace) {
      log.e('@saveReminderTime: Error saving reminder time', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves a [ReminderTime] entity by its [id].
  Future<ReminderTime?> getReminderTime(Id id) async {
    try {
      log.d('@getReminderTime: Fetching reminder time with id $id');
      return await _isar.reminderTimes.get(id);
    } catch (e, stackTrace) {
      log.e('@getReminderTime: Error getting reminder time $id', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves all [ReminderTime] entities from the database.
  Future<List<ReminderTime>> getAllReminderTimes() async {
    try {
      log.d('@getAllReminderTimes: Fetching all reminder times');
      return await _isar.reminderTimes.where().findAll();
    } catch (e, stackTrace) {
      log.e('@getAllReminderTimes: Error getting all reminder times', e, stackTrace);
      rethrow;
    }
  }

  /// Updates an existing [ReminderTime] entity and its relationships.
  Future<Id> updateReminderTime(ReminderTime reminderTime) async {
    try {
      log.d('@updateReminderTime: Updating reminder time with id ${reminderTime.id}');
      return await _isar.writeTxn(() async {
        final id = await _isar.reminderTimes.put(reminderTime);
        await reminderTime.medicine.save();
        return id;
      });
    } catch (e, stackTrace) {
      log.e('@updateReminderTime: Error updating reminder time ${reminderTime.id}', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes a [ReminderTime] entity by its [id].
  Future<bool> deleteReminderTime(Id id) async {
    try {
      log.d('@deleteReminderTime: Deleting reminder time with id $id');
      return await _isar.writeTxn(() async {
        return await _isar.reminderTimes.delete(id);
      });
    } catch (e, stackTrace) {
      log.e('@deleteReminderTime: Error deleting reminder time $id', e, stackTrace);
      rethrow;
    }
  }
}
