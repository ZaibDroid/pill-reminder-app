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
import 'package:pill_reminder_app/ui/viewmodels/history_viewmodel.dart';

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
    tempDir = await Directory.systemTemp.createTemp('isar_history_vm_test_');
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

  group('HistoryViewModel Tests', () {
    test('Empty history returns zero dose items and zero adherence rate', () async {
      final vm = HistoryViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      final date = DateTime(2026, 9, 1);
      await vm.loadHistoryForDate(date);

      expect(vm.isLoading, isFalse);
      expect(vm.hasError, isFalse);
      expect(vm.isEmpty, isTrue);
      expect(vm.items, isEmpty);
      expect(vm.totalDosesCount, equals(0));
      expect(vm.adherenceRate, equals(0.0));
      expect(vm.motivationalMessage, equals('No medications scheduled for today.'));
    });

    test('Real DoseLog and active medicines are loaded with accurate statuses', () async {
      final date = DateTime(2026, 9, 1);

      // Create medicine
      final med = Medicine()
        ..name = 'Metformin'
        ..dosageValue = 500
        ..dosageUnit = 'mg'
        ..frequency = FrequencyType.daily
        ..mealType = MealType.withMeal
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med);

      // Create reminder 08:00
      final reminder = ReminderTime()
        ..hour = 8
        ..minute = 0
        ..isActive = true;
      reminder.medicine.value = med;
      await reminderRepository.saveReminderTime(reminder);
      med.reminders.add(reminder);
      await medicineRepository.updateMedicine(med);

      // Create taken dose log
      final log = DoseLog()
        ..status = MedicineStatus.taken
        ..scheduledDateTime = DateTime(2026, 9, 1, 8, 0)
        ..actualTakenDateTime = DateTime(2026, 9, 1, 8, 5);
      log.medicine.value = med;
      log.reminderTime.value = reminder;
      await doseLogRepository.saveDoseLog(log);

      final vm = HistoryViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      await vm.loadHistoryForDate(date);

      expect(vm.items.length, equals(1));
      final item = vm.items.first;
      expect(item.medicine.name, equals('Metformin'));
      expect(item.status, equals(MedicineStatus.taken));
      expect(item.doseLog?.actualTakenDateTime, isNotNull);
      expect(vm.takenDosesCount, equals(1));
      expect(vm.totalDosesCount, equals(1));
      expect(vm.adherenceRate, equals(100.0));
    });

    test('Date filtering loads history specific to the selected date', () async {
      final day1 = DateTime(2026, 9, 1);
      final day2 = DateTime(2026, 9, 2);

      final med = Medicine()
        ..name = 'Atorvastatin'
        ..dosageValue = 20
        ..dosageUnit = 'mg'
        ..frequency = FrequencyType.daily
        ..mealType = MealType.afterMeal
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med);

      final reminder = ReminderTime()
        ..hour = 20
        ..minute = 0
        ..isActive = true;
      reminder.medicine.value = med;
      await reminderRepository.saveReminderTime(reminder);
      med.reminders.add(reminder);
      await medicineRepository.updateMedicine(med);

      // Save log only on day 1
      final log = DoseLog()
        ..status = MedicineStatus.taken
        ..scheduledDateTime = DateTime(2026, 9, 1, 20, 0)
        ..actualTakenDateTime = DateTime(2026, 9, 1, 20, 10);
      log.medicine.value = med;
      log.reminderTime.value = reminder;
      await doseLogRepository.saveDoseLog(log);

      final vm = HistoryViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      // Load day 1 -> Taken
      await vm.loadHistoryForDate(day1);
      expect(vm.items.length, equals(1));
      expect(vm.items.first.status, equals(MedicineStatus.taken));
      expect(vm.takenDosesCount, equals(1));

      // Load day 2 -> Pending (no log saved for day 2 yet)
      vm.selectDate(day2);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(vm.items.length, equals(1));
      expect(vm.items.first.status, equals(MedicineStatus.pending));
      expect(vm.takenDosesCount, equals(0));
    });

    test('Multiple medicines with mixed statuses (Taken, Skipped, Missed, Pending)', () async {
      final date = DateTime(2026, 9, 1);

      final med1 = Medicine()
        ..name = 'Med A'
        ..dosageValue = 10
        ..dosageUnit = 'mg'
        ..frequency = FrequencyType.daily
        ..mealType = MealType.beforeMeal
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med1);

      final rem1 = ReminderTime()
        ..hour = 8
        ..minute = 0
        ..isActive = true;
      rem1.medicine.value = med1;
      await reminderRepository.saveReminderTime(rem1);
      med1.reminders.add(rem1);
      await medicineRepository.updateMedicine(med1);

      final med2 = Medicine()
        ..name = 'Med B'
        ..dosageValue = 20
        ..dosageUnit = 'mg'
        ..frequency = FrequencyType.daily
        ..mealType = MealType.afterMeal
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med2);

      final rem2 = ReminderTime()
        ..hour = 12
        ..minute = 0
        ..isActive = true;
      rem2.medicine.value = med2;
      await reminderRepository.saveReminderTime(rem2);
      med2.reminders.add(rem2);
      await medicineRepository.updateMedicine(med2);

      // Med1 taken, Med2 skipped
      final log1 = DoseLog()
        ..status = MedicineStatus.taken
        ..scheduledDateTime = DateTime(2026, 9, 1, 8, 0)
        ..actualTakenDateTime = DateTime(2026, 9, 1, 8, 0);
      log1.medicine.value = med1;
      log1.reminderTime.value = rem1;
      await doseLogRepository.saveDoseLog(log1);

      final log2 = DoseLog()
        ..status = MedicineStatus.skipped
        ..scheduledDateTime = DateTime(2026, 9, 1, 12, 0);
      log2.medicine.value = med2;
      log2.reminderTime.value = rem2;
      await doseLogRepository.saveDoseLog(log2);

      final vm = HistoryViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      await vm.loadHistoryForDate(date);

      expect(vm.items.length, equals(2));
      expect(vm.takenDosesCount, equals(1));
      expect(vm.skippedDosesCount, equals(1));
      expect(vm.missedDosesCount, equals(0));
      // Adherence rate: 1 taken / (2 total - 1 skipped) = 100%
      expect(vm.adherenceRate, equals(100.0));
    });

    test('Handles error states gracefully when repository fails', () async {
      await databaseService.close(deleteFromDisk: true);

      final vm = HistoryViewModel(
        doseLogRepository: doseLogRepository,
        medicineRepository: medicineRepository,
      );

      await vm.loadHistoryForDate(DateTime.now());

      expect(vm.hasError, isTrue);
      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });
}
