import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/core/repositories/reminder_repository.dart';
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late ReminderRepository reminderRepository;
  late MedicineRepository medicineRepository;
  late Directory tempDir;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_reminder_test_');
    databaseService = DatabaseService();
    await databaseService.init(
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    reminderRepository = ReminderRepository(databaseService: databaseService);
    medicineRepository = MedicineRepository(databaseService: databaseService);
  });

  tearDown(() async {
    if (databaseService.isOpen) {
      await databaseService.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ReminderRepository CRUD & Relationship Tests', () {
    test('saveReminderTime creates a new reminder and links to a Medicine', () async {
      // 1. Create and save a Medicine
      final medicine = Medicine()
        ..name = 'Metformin'
        ..dosageValue = 500.0;
      await medicineRepository.saveMedicine(medicine);

      // 2. Create ReminderTime and link Medicine
      final reminder = ReminderTime()
        ..hour = 9
        ..minute = 30
        ..isActive = true
        ..soundRingtone = 'gentle_bell'
        ..isVibrationEnabled = true;
      reminder.medicine.value = medicine;

      final reminderId = await reminderRepository.saveReminderTime(reminder);

      expect(reminderId, isPositive);
      expect(reminder.id, equals(reminderId));

      // 3. Verify link
      final retrieved = await reminderRepository.getReminderTime(reminderId);
      expect(retrieved, isNotNull);
      expect(retrieved!.hour, equals(9));
      expect(retrieved.minute, equals(30));
      await retrieved.medicine.load();
      expect(retrieved.medicine.value, isNotNull);
      expect(retrieved.medicine.value!.name, equals('Metformin'));
    });

    test('getReminderTime retrieves existing reminder time correctly', () async {
      final reminder = ReminderTime()
        ..hour = 14
        ..minute = 15
        ..soundRingtone = 'alarm_clock'
        ..isActive = true;

      final id = await reminderRepository.saveReminderTime(reminder);
      final retrieved = await reminderRepository.getReminderTime(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.hour, equals(14));
      expect(retrieved.minute, equals(15));
      expect(retrieved.soundRingtone, equals('alarm_clock'));
    });

    test('getAllReminderTimes fetches all saved reminder records', () async {
      final r1 = ReminderTime()..hour = 8..minute = 0;
      final r2 = ReminderTime()..hour = 12..minute = 30;
      final r3 = ReminderTime()..hour = 20..minute = 0;

      await reminderRepository.saveReminderTime(r1);
      await reminderRepository.saveReminderTime(r2);
      await reminderRepository.saveReminderTime(r3);

      final allReminders = await reminderRepository.getAllReminderTimes();
      expect(allReminders.length, equals(3));
      expect(allReminders.map((r) => r.hour), containsAll([8, 12, 20]));
    });

    test('updateReminderTime updates time, status, and sound properties', () async {
      final reminder = ReminderTime()
        ..hour = 8
        ..minute = 0
        ..isActive = true
        ..soundRingtone = 'default';

      final id = await reminderRepository.saveReminderTime(reminder);

      reminder.hour = 9;
      reminder.minute = 45;
      reminder.isActive = false;
      reminder.soundRingtone = 'chime';

      await reminderRepository.updateReminderTime(reminder);

      final updated = await reminderRepository.getReminderTime(id);
      expect(updated, isNotNull);
      expect(updated!.hour, equals(9));
      expect(updated.minute, equals(45));
      expect(updated.isActive, isFalse);
      expect(updated.soundRingtone, equals('chime'));
    });

    test('deleteReminderTime removes the reminder time record', () async {
      final reminder = ReminderTime()
        ..hour = 22
        ..minute = 0;

      final id = await reminderRepository.saveReminderTime(reminder);
      final deleteSuccess = await reminderRepository.deleteReminderTime(id);

      expect(deleteSuccess, isTrue);

      final retrieved = await reminderRepository.getReminderTime(id);
      expect(retrieved, isNull);

      final allReminders = await reminderRepository.getAllReminderTimes();
      expect(allReminders, isEmpty);
    });
  });
}
