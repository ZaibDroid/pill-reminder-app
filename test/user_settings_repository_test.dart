import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/core/repositories/user_settings_repository.dart';
import 'package:pill_reminder_app/core/models/user_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late UserSettingsRepository userSettingsRepository;
  late Directory tempDir;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_settings_test_');
    databaseService = DatabaseService();
    await databaseService.init(
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    userSettingsRepository = UserSettingsRepository(databaseService: databaseService);
  });

  tearDown(() async {
    if (databaseService.isOpen) {
      await databaseService.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('UserSettingsRepository CRUD & Singleton Tests', () {
    test('getOrCreateSettings creates default settings when none exist', () async {
      final settings = await userSettingsRepository.getOrCreateSettings();

      expect(settings.id, isPositive);
      expect(settings.themeMode, equals('system'));
      expect(settings.snoozeDurationMinutes, equals(10));
      expect(settings.gracePeriodMinutes, equals(30));
      expect(settings.isFirstTimeUser, isTrue);
      expect(settings.isBiometricEnabled, isFalse);
    });

    test('getOrCreateSettings returns existing settings without creating duplicates', () async {
      final first = await userSettingsRepository.getOrCreateSettings();
      final second = await userSettingsRepository.getOrCreateSettings();

      expect(first.id, equals(second.id));

      final allSettings = await databaseService.isar.userSettings.where().findAll();
      expect(allSettings.length, equals(1));
    });

    test('saveUserSettings enforces a single active settings record', () async {
      final settings1 = UserSettings()..themeMode = 'light';
      await userSettingsRepository.saveUserSettings(settings1);

      final settings2 = UserSettings()..themeMode = 'dark';
      await userSettingsRepository.saveUserSettings(settings2);

      final active = await userSettingsRepository.getUserSettings();
      expect(active, isNotNull);
      expect(active!.id, equals(settings2.id));
      expect(active.themeMode, equals('dark'));

      final count = await databaseService.isar.userSettings.count();
      expect(count, equals(1));
    });

    test('updateUserSettings updates properties and updatedAt timestamp', () async {
      final settings = await userSettingsRepository.getOrCreateSettings();
      final initialUpdatedAt = settings.updatedAt;

      await Future.delayed(const Duration(milliseconds: 10));

      settings.themeMode = 'dark';
      settings.snoozeDurationMinutes = 15;
      settings.isFirstTimeUser = false;
      settings.isBiometricEnabled = true;

      await userSettingsRepository.updateUserSettings(settings);

      final updated = await userSettingsRepository.getUserSettings();
      expect(updated, isNotNull);
      expect(updated!.themeMode, equals('dark'));
      expect(updated.snoozeDurationMinutes, equals(15));
      expect(updated.isFirstTimeUser, isFalse);
      expect(updated.isBiometricEnabled, isTrue);
      expect(updated.updatedAt.isAfter(initialUpdatedAt), isTrue);
    });

    test('deleteUserSettings removes settings record', () async {
      final settings = await userSettingsRepository.getOrCreateSettings();

      final deleted = await userSettingsRepository.deleteUserSettings(id: settings.id);
      expect(deleted, isTrue);

      final retrieved = await userSettingsRepository.getUserSettings();
      expect(retrieved, isNull);
    });
  });
}
