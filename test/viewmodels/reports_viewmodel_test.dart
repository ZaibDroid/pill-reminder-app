import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/enums/frequency_type.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';
import 'package:pill_reminder_app/core/models/dose_log.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/repositories/dose_log_repository.dart';
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/repositories/reminder_repository.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/ui/viewmodels/reports_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late DatabaseService databaseService;
  late MedicineRepository medicineRepository;
  late DoseLogRepository doseLogRepository;
  late ReminderRepository reminderRepository;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_reports_vm_test_');
    databaseService = DatabaseService();
    await databaseService.init(
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    medicineRepository = MedicineRepository(databaseService: databaseService);
    doseLogRepository = DoseLogRepository(databaseService: databaseService);
    reminderRepository = ReminderRepository(databaseService: databaseService);
  });

  tearDown(() async {
    await databaseService.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  group('ReportsViewModel Tests', () {
    test('Empty report state returns zero metrics and valid empty state flags', () async {
      final vm = ReportsViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      final month = DateTime(2026, 9, 1);
      await vm.loadMonthlyReports(month: month);

      expect(vm.isLoading, isFalse);
      expect(vm.hasError, isFalse);
      expect(vm.isEmpty, isTrue);
      expect(vm.totalScheduledCount, equals(0));
      expect(vm.takenCount, equals(0));
      expect(vm.skippedCount, equals(0));
      expect(vm.missedCount, equals(0));
      expect(vm.adherenceRate, equals(0.0));
      expect(vm.takenPercentage, equals(0.0));
      expect(vm.longestStreakDays, equals(0));
    });

    test('Computes adherence, taken/skipped/missed counts, and chart percentages accurately', () async {
      final month = DateTime(2026, 9, 1);

      // Create medicine active for September
      final med = Medicine()
        ..name = 'Lisinopril'
        ..dosageValue = 10
        ..dosageUnit = 'mg'
        ..frequency = FrequencyType.daily
        ..mealType = MealType.afterMeal
        ..startDate = DateTime(2026, 9, 1)
        ..endDate = DateTime(2026, 9, 3)
        ..isOngoing = false; // 3 days: Sep 1, 2, 3
      await medicineRepository.saveMedicine(med);

      final reminder = ReminderTime()
        ..hour = 8
        ..minute = 0
        ..isActive = true;
      reminder.medicine.value = med;
      await reminderRepository.saveReminderTime(reminder);
      med.reminders.add(reminder);
      await medicineRepository.updateMedicine(med);

      // Day 1: Taken
      final log1 = DoseLog()
        ..status = MedicineStatus.taken
        ..scheduledDateTime = DateTime(2026, 9, 1, 8, 0)
        ..actualTakenDateTime = DateTime(2026, 9, 1, 8, 15);
      log1.medicine.value = med;
      log1.reminderTime.value = reminder;
      await doseLogRepository.saveDoseLog(log1);

      // Day 2: Skipped
      final log2 = DoseLog()
        ..status = MedicineStatus.skipped
        ..scheduledDateTime = DateTime(2026, 9, 2, 8, 0);
      log2.medicine.value = med;
      log2.reminderTime.value = reminder;
      await doseLogRepository.saveDoseLog(log2);

      // Day 3: Missed
      final log3 = DoseLog()
        ..status = MedicineStatus.missed
        ..scheduledDateTime = DateTime(2026, 9, 3, 8, 0);
      log3.medicine.value = med;
      log3.reminderTime.value = reminder;
      await doseLogRepository.saveDoseLog(log3);

      final vm = ReportsViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      await vm.loadMonthlyReports(month: month);

      expect(vm.totalScheduledCount, equals(3));
      expect(vm.takenCount, equals(1));
      expect(vm.skippedCount, equals(1));
      expect(vm.missedCount, equals(1));

      // Formula: 1 taken / (3 total - 1 skipped) = 1 / 2 = 50.0%
      expect(vm.adherenceRate, equals(50.0));
      expect(vm.takenPercentage, closeTo(33.3, 0.1));
      expect(vm.skippedPercentage, closeTo(33.3, 0.1));
      expect(vm.missedPercentage, closeTo(33.3, 0.1));
    });

    test('Generates daily adherence heatmap data for all days in month', () async {
      final month = DateTime(2026, 9, 1);

      final med = Medicine()
        ..name = 'Metformin'
        ..dosageValue = 500
        ..dosageUnit = 'mg'
        ..frequency = FrequencyType.daily
        ..mealType = MealType.withMeal
        ..startDate = DateTime(2026, 9, 1)
        ..endDate = DateTime(2026, 9, 2)
        ..isOngoing = false;
      await medicineRepository.saveMedicine(med);

      final rem = ReminderTime()
        ..hour = 9
        ..minute = 0
        ..isActive = true;
      rem.medicine.value = med;
      await reminderRepository.saveReminderTime(rem);
      med.reminders.add(rem);
      await medicineRepository.updateMedicine(med);

      // Day 1 taken
      final log1 = DoseLog()
        ..status = MedicineStatus.taken
        ..scheduledDateTime = DateTime(2026, 9, 1, 9, 0)
        ..actualTakenDateTime = DateTime(2026, 9, 1, 9, 5);
      log1.medicine.value = med;
      log1.reminderTime.value = rem;
      await doseLogRepository.saveDoseLog(log1);

      final vm = ReportsViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      await vm.loadMonthlyReports(month: month);

      expect(vm.dailyDoseCounts[1], equals(1));
      expect(vm.dailyAdherenceRates[1], equals(100.0));
      expect(vm.dailyDoseCounts[2], equals(1));
      expect(vm.dailyAdherenceRates[2], equals(0.0)); // Not logged yet = pending/0%
      expect(vm.dailyDoseCounts[3], equals(0)); // Medication course ended
    });

    test('PDF Document generates valid document with structured tables and stats', () async {
      final month = DateTime(2026, 9, 1);

      final med = Medicine()
        ..name = 'Aspirin'
        ..dosageValue = 81
        ..dosageUnit = 'mg'
        ..frequency = FrequencyType.daily
        ..mealType = MealType.afterMeal
        ..startDate = DateTime(2026, 9, 1);
      await medicineRepository.saveMedicine(med);

      final rem = ReminderTime()
        ..hour = 8
        ..minute = 0
        ..isActive = true;
      rem.medicine.value = med;
      await reminderRepository.saveReminderTime(rem);
      med.reminders.add(rem);
      await medicineRepository.updateMedicine(med);

      final log = DoseLog()
        ..status = MedicineStatus.taken
        ..scheduledDateTime = DateTime(2026, 9, 1, 8, 0)
        ..actualTakenDateTime = DateTime(2026, 9, 1, 8, 5);
      log.medicine.value = med;
      log.reminderTime.value = rem;
      await doseLogRepository.saveDoseLog(log);

      final vm = ReportsViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      await vm.loadMonthlyReports(month: month);

      final doc = vm.generatePdfReport();
      expect(doc, isNotNull);

      // Verify that pdf document bytes can be generated cleanly in pure Dart
      final bytes = await doc.save();
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(500));
    });

    test('Handles database errors gracefully and sets hasError state', () async {
      await databaseService.close(deleteFromDisk: true);

      final vm = ReportsViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      await vm.loadMonthlyReports();

      expect(vm.hasError, isTrue);
      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });
}
