import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/repositories/reminder_repository.dart';
import 'package:pill_reminder_app/core/repositories/dose_log_repository.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/models/dose_log.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/enums/frequency_type.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late MedicineRepository medicineRepository;
  late ReminderRepository reminderRepository;
  late DoseLogRepository doseLogRepository;
  late Directory tempDir;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_repo_test_');
    databaseService = DatabaseService();
    await databaseService.init(
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    medicineRepository = MedicineRepository(databaseService: databaseService);
    reminderRepository = ReminderRepository(databaseService: databaseService);
    doseLogRepository = DoseLogRepository(databaseService: databaseService);
  });

  tearDown(() async {
    if (databaseService.isOpen) {
      await databaseService.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('MedicineRepository CRUD Tests', () {
    test('saveMedicine persists a new medicine and returns a valid ID', () async {
      final medicine = Medicine()
        ..name = 'Metformin'
        ..dosageValue = 850.0
        ..dosageUnit = 'mg'
        ..mealType = MealType.withMeal
        ..frequency = FrequencyType.daily
        ..currentStock = 60
        ..lowStockThreshold = 10
        ..isRefillAlertEnabled = true;

      final id = await medicineRepository.saveMedicine(medicine);

      expect(id, isPositive);
      expect(medicine.id, equals(id));
    });

    test('getMedicine retrieves medicine by ID accurately', () async {
      final medicine = Medicine()
        ..name = 'Lisinopril'
        ..dosageValue = 10.0
        ..dosageUnit = 'mg'
        ..mealType = MealType.noRelation
        ..frequency = FrequencyType.daily
        ..currentStock = 30;

      final id = await medicineRepository.saveMedicine(medicine);
      final retrieved = await medicineRepository.getMedicine(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Lisinopril'));
      expect(retrieved.dosageValue, equals(10.0));
      expect(retrieved.dosageUnit, equals('mg'));
    });

    test('getAllMedicines returns all saved medicines', () async {
      final med1 = Medicine()
        ..name = 'Aspirin'
        ..dosageValue = 100.0;
      final med2 = Medicine()
        ..name = 'Ibuprofen'
        ..dosageValue = 400.0;

      await medicineRepository.saveMedicine(med1);
      await medicineRepository.saveMedicine(med2);

      final allMedicines = await medicineRepository.getAllMedicines();
      expect(allMedicines.length, equals(2));
      expect(allMedicines.map((m) => m.name), containsAll(['Aspirin', 'Ibuprofen']));
    });

    test('updateMedicine modifies fields and updates updatedAt timestamp', () async {
      final medicine = Medicine()
        ..name = 'Atorvastatin'
        ..dosageValue = 20.0
        ..currentStock = 30;

      final id = await medicineRepository.saveMedicine(medicine);
      final initialUpdatedAt = medicine.updatedAt;

      // Small delay to ensure timestamp change
      await Future.delayed(const Duration(milliseconds: 10));

      medicine.dosageValue = 40.0;
      medicine.currentStock = 25;

      await medicineRepository.updateMedicine(medicine);

      final updated = await medicineRepository.getMedicine(id);
      expect(updated, isNotNull);
      expect(updated!.dosageValue, equals(40.0));
      expect(updated.currentStock, equals(25));
      expect(updated.updatedAt.isAfter(initialUpdatedAt), isTrue);
    });

    test('deleteMedicine removes medicine from database', () async {
      final medicine = Medicine()
        ..name = 'Paracetamol'
        ..dosageValue = 500.0;

      final id = await medicineRepository.saveMedicine(medicine);
      final deleteSuccess = await medicineRepository.deleteMedicine(id);

      expect(deleteSuccess, isTrue);

      final retrieved = await medicineRepository.getMedicine(id);
      expect(retrieved, isNull);

      final allMedicines = await medicineRepository.getAllMedicines();
      expect(allMedicines, isEmpty);
    });

    test('deleteMedicine cascades deletion to linked ReminderTimes while preserving DoseLogs', () async {
      // 1. Create and persist a Medicine
      final medicine = Medicine()
        ..name = 'Amoxicillin'
        ..dosageValue = 500.0;
      final medId = await medicineRepository.saveMedicine(medicine);

      // 2. Create and link 2 ReminderTimes
      final reminder1 = ReminderTime()..hour = 8..minute = 0;
      reminder1.medicine.value = medicine;
      final rem1Id = await reminderRepository.saveReminderTime(reminder1);

      final reminder2 = ReminderTime()..hour = 20..minute = 0;
      reminder2.medicine.value = medicine;
      final rem2Id = await reminderRepository.saveReminderTime(reminder2);

      medicine.reminders.addAll([reminder1, reminder2]);
      await medicineRepository.updateMedicine(medicine);

      // 3. Create historical DoseLog linked to this Medicine
      final doseLog = DoseLog()
        ..scheduledDateTime = DateTime(2026, 8, 25, 8, 0)
        ..status = MedicineStatus.taken
        ..actualTakenDateTime = DateTime(2026, 8, 25, 8, 2);
      doseLog.medicine.value = medicine;
      doseLog.reminderTime.value = reminder1;
      final logId = await doseLogRepository.saveDoseLog(doseLog);

      // Verify all 3 entities exist prior to deletion
      expect(await medicineRepository.getMedicine(medId), isNotNull);
      expect(await reminderRepository.getReminderTime(rem1Id), isNotNull);
      expect(await reminderRepository.getReminderTime(rem2Id), isNotNull);
      expect(await doseLogRepository.getDoseLog(logId), isNotNull);

      // 4. Perform Cascade Delete on Medicine
      final deleteSuccess = await medicineRepository.deleteMedicine(medId);
      expect(deleteSuccess, isTrue);

      // Proof 1: Medicine is deleted
      final deletedMedicine = await medicineRepository.getMedicine(medId);
      expect(deletedMedicine, isNull);

      // Proof 2: Linked ReminderTimes are deleted
      final deletedRem1 = await reminderRepository.getReminderTime(rem1Id);
      final deletedRem2 = await reminderRepository.getReminderTime(rem2Id);
      expect(deletedRem1, isNull);
      expect(deletedRem2, isNull);

      final allReminders = await reminderRepository.getAllReminderTimes();
      expect(allReminders, isEmpty);

      // Proof 3: DoseLog history is preserved
      final preservedLog = await doseLogRepository.getDoseLog(logId);
      expect(preservedLog, isNotNull);
      expect(preservedLog!.status, equals(MedicineStatus.taken));
      expect(preservedLog.scheduledDateTime, equals(DateTime(2026, 8, 25, 8, 0)));
    });
  });
}
