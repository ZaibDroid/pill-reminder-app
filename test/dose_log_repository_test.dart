import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/core/repositories/dose_log_repository.dart';
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/repositories/reminder_repository.dart';
import 'package:pill_reminder_app/core/models/dose_log.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late DoseLogRepository doseLogRepository;
  late MedicineRepository medicineRepository;
  late ReminderRepository reminderRepository;
  late Directory tempDir;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_doselog_test_');
    databaseService = DatabaseService();
    await databaseService.init(
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    doseLogRepository = DoseLogRepository(databaseService: databaseService);
    medicineRepository = MedicineRepository(databaseService: databaseService);
    reminderRepository = ReminderRepository(databaseService: databaseService);
  });

  tearDown(() async {
    if (databaseService.isOpen) {
      await databaseService.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('DoseLogRepository CRUD & Query Tests', () {
    test('saveDoseLog saves a dose log and associates Medicine and ReminderTime', () async {
      // Create Medicine
      final medicine = Medicine()..name = 'Amoxicillin';
      await medicineRepository.saveMedicine(medicine);

      // Create ReminderTime
      final reminder = ReminderTime()..hour = 8..minute = 0;
      await reminderRepository.saveReminderTime(reminder);

      // Create DoseLog
      final scheduledTime = DateTime(2026, 8, 25, 8, 0);
      final doseLog = DoseLog()
        ..scheduledDateTime = scheduledTime
        ..status = MedicineStatus.pending;
      doseLog.medicine.value = medicine;
      doseLog.reminderTime.value = reminder;

      final id = await doseLogRepository.saveDoseLog(doseLog);

      expect(id, isPositive);
      expect(doseLog.id, equals(id));

      // Verify retrieved links
      final retrieved = await doseLogRepository.getDoseLog(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.scheduledDateTime, equals(scheduledTime));
      expect(retrieved.status, equals(MedicineStatus.pending));

      await retrieved.medicine.load();
      await retrieved.reminderTime.load();
      expect(retrieved.medicine.value?.name, equals('Amoxicillin'));
      expect(retrieved.reminderTime.value?.hour, equals(8));
    });

    test('getDoseLog and getAllDoseLogs retrieve persisted dose logs', () async {
      final log1 = DoseLog()..scheduledDateTime = DateTime(2026, 8, 25, 8, 0);
      final log2 = DoseLog()..scheduledDateTime = DateTime(2026, 8, 25, 12, 0);

      await doseLogRepository.saveDoseLog(log1);
      await doseLogRepository.saveDoseLog(log2);

      final allLogs = await doseLogRepository.getAllDoseLogs();
      expect(allLogs.length, equals(2));

      final retrieved1 = await doseLogRepository.getDoseLog(log1.id);
      expect(retrieved1, isNotNull);
      expect(retrieved1!.id, equals(log1.id));
    });

    test('updateDoseLog updates dose status to taken with actual timestamp and notes', () async {
      final doseLog = DoseLog()
        ..scheduledDateTime = DateTime(2026, 8, 25, 8, 0)
        ..status = MedicineStatus.pending;

      final id = await doseLogRepository.saveDoseLog(doseLog);

      final takenTime = DateTime(2026, 8, 25, 8, 5);
      doseLog.status = MedicineStatus.taken;
      doseLog.actualTakenDateTime = takenTime;
      doseLog.notes = 'Taken with water';

      await doseLogRepository.updateDoseLog(doseLog);

      final updated = await doseLogRepository.getDoseLog(id);
      expect(updated, isNotNull);
      expect(updated!.status, equals(MedicineStatus.taken));
      expect(updated.actualTakenDateTime, equals(takenTime));
      expect(updated.notes, equals('Taken with water'));
    });

    test('deleteDoseLog removes the dose log from the database', () async {
      final doseLog = DoseLog()..scheduledDateTime = DateTime(2026, 8, 25, 8, 0);

      final id = await doseLogRepository.saveDoseLog(doseLog);
      final deleteResult = await doseLogRepository.deleteDoseLog(id);

      expect(deleteResult, isTrue);

      final retrieved = await doseLogRepository.getDoseLog(id);
      expect(retrieved, isNull);
    });

    test('getDoseLogsForDateRange retrieves only logs within specified time window', () async {
      final day1 = DoseLog()..scheduledDateTime = DateTime(2026, 8, 24, 10, 0);
      final day2Morning = DoseLog()..scheduledDateTime = DateTime(2026, 8, 25, 8, 0);
      final day2Evening = DoseLog()..scheduledDateTime = DateTime(2026, 8, 25, 20, 0);
      final day3 = DoseLog()..scheduledDateTime = DateTime(2026, 8, 26, 10, 0);

      await doseLogRepository.saveDoseLog(day1);
      await doseLogRepository.saveDoseLog(day2Morning);
      await doseLogRepository.saveDoseLog(day2Evening);
      await doseLogRepository.saveDoseLog(day3);

      final rangeStart = DateTime(2026, 8, 25, 0, 0);
      final rangeEnd = DateTime(2026, 8, 25, 23, 59, 59);

      final day2Logs = await doseLogRepository.getDoseLogsForDateRange(rangeStart, rangeEnd);
      expect(day2Logs.length, equals(2));
      expect(day2Logs.map((l) => l.id), containsAll([day2Morning.id, day2Evening.id]));
    });

    test('getDoseLogsForMedicine retrieves logs for a specific medicine', () async {
      final medA = Medicine()..name = 'Medicine A';
      final medB = Medicine()..name = 'Medicine B';
      await medicineRepository.saveMedicine(medA);
      await medicineRepository.saveMedicine(medB);

      final logA1 = DoseLog()..scheduledDateTime = DateTime(2026, 8, 25, 8, 0);
      logA1.medicine.value = medA;
      final logA2 = DoseLog()..scheduledDateTime = DateTime(2026, 8, 25, 20, 0);
      logA2.medicine.value = medA;

      final logB1 = DoseLog()..scheduledDateTime = DateTime(2026, 8, 25, 9, 0);
      logB1.medicine.value = medB;

      await doseLogRepository.saveDoseLog(logA1);
      await doseLogRepository.saveDoseLog(logA2);
      await doseLogRepository.saveDoseLog(logB1);

      final medALogs = await doseLogRepository.getDoseLogsForMedicine(medA.id);
      expect(medALogs.length, equals(2));
      expect(medALogs.map((l) => l.id), containsAll([logA1.id, logA2.id]));

      final medBLogs = await doseLogRepository.getDoseLogsForMedicine(medB.id);
      expect(medBLogs.length, equals(1));
      expect(medBLogs.first.id, equals(logB1.id));
    });
  });
}
