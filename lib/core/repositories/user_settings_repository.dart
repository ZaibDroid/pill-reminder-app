import 'package:isar/isar.dart';
import '../../app/locator.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../utils/custom_logger.dart';

class UserSettingsRepository {
  final log = CustomLogger(className: '@UserSettingsRepository');
  final DatabaseService _databaseService;

  UserSettingsRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? locator<DatabaseService>();

  Isar get _isar => _databaseService.isar;

  /// Retrieves the existing [UserSettings] record, or null if none exists.
  Future<UserSettings?> getUserSettings({Id? id}) async {
    try {
      log.d('@getUserSettings: Fetching user settings');
      if (id != null) {
        return await _isar.userSettings.get(id);
      }
      return await _isar.userSettings.where().findFirst();
    } catch (e, stackTrace) {
      log.e('@getUserSettings: Error getting user settings', e, stackTrace);
      rethrow;
    }
  }

  /// Retrieves the active [UserSettings], or creates and saves a default record if none exists.
  Future<UserSettings> getOrCreateSettings() async {
    try {
      log.d('@getOrCreateSettings: Fetching or creating default user settings');
      final existing = await _isar.userSettings.where().findFirst();
      if (existing != null) {
        return existing;
      }

      final defaultSettings = UserSettings()..updatedAt = DateTime.now();
      await _isar.writeTxn(() async {
        await _isar.userSettings.put(defaultSettings);
      });
      log.i('@getOrCreateSettings: Created default user settings with ID ${defaultSettings.id}');
      return defaultSettings;
    } catch (e, stackTrace) {
      log.e('@getOrCreateSettings: Error getting or creating user settings', e, stackTrace);
      rethrow;
    }
  }

  /// Saves [UserSettings], maintaining only a single active settings record in the database.
  Future<Id> saveUserSettings(UserSettings settings) async {
    try {
      log.d('@saveUserSettings: Saving user settings');
      settings.updatedAt = DateTime.now();
      return await _isar.writeTxn(() async {
        final existingSettings = await _isar.userSettings.where().findAll();
        for (final item in existingSettings) {
          if (item.id != settings.id) {
            await _isar.userSettings.delete(item.id);
          }
        }
        return await _isar.userSettings.put(settings);
      });
    } catch (e, stackTrace) {
      log.e('@saveUserSettings: Error saving user settings', e, stackTrace);
      rethrow;
    }
  }

  /// Updates the existing [UserSettings] record.
  Future<Id> updateUserSettings(UserSettings settings) async {
    try {
      log.d('@updateUserSettings: Updating user settings with ID ${settings.id}');
      settings.updatedAt = DateTime.now();
      return await _isar.writeTxn(() async {
        return await _isar.userSettings.put(settings);
      });
    } catch (e, stackTrace) {
      log.e('@updateUserSettings: Error updating user settings', e, stackTrace);
      rethrow;
    }
  }

  /// Deletes a [UserSettings] record by its [id] (or all settings if id is omitted).
  Future<bool> deleteUserSettings({Id? id}) async {
    try {
      log.d('@deleteUserSettings: Deleting user settings');
      return await _isar.writeTxn(() async {
        if (id != null) {
          return await _isar.userSettings.delete(id);
        } else {
          final count = await _isar.userSettings.where().deleteAll();
          return count > 0;
        }
      });
    } catch (e, stackTrace) {
      log.e('@deleteUserSettings: Error deleting user settings', e, stackTrace);
      rethrow;
    }
  }
}
