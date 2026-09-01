import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/enums/frequency_type.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';
import 'package:pill_reminder_app/core/enums/view_state.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/repositories/dose_log_repository.dart';
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/repositories/reminder_repository.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/ui/viewmodels/home_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late MedicineRepository medicineRepository;
  late DoseLogRepository doseLogRepository;
  late ReminderRepository reminderRepository;
  late Directory tempDir;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_home_vm_test_');
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
    if (databaseService.isOpen) {
      await databaseService.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('HomeViewModel Tests', () {
    test('Initial state of HomeViewModel is correct', () {
      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      expect(viewModel.state, equals(ViewState.idle));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.isEmpty, isTrue);
      expect(viewModel.isSuccess, isFalse);
      expect(viewModel.activeMedicines, isEmpty);
      expect(viewModel.todayDoseLogs, isEmpty);
      expect(viewModel.timelineItems, isEmpty);
      expect(viewModel.totalDosesCount, equals(0));
      expect(viewModel.adherenceRate, equals(0.0));
      expect(viewModel.isToday, isTrue);
    });

    test('loadTodayTimeline loads active medicines and generates timeline items chronologically', () async {
      final testDate = DateTime(2026, 8, 28);

      final med = Medicine()
        ..name = 'Metformin'
        ..dosageValue = 500
        ..dosageUnit = 'mg'
        ..mealType = MealType.afterMeal
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1);

      await medicineRepository.saveMedicine(med);

      final reminderMorning = ReminderTime()
        ..hour = 8
        ..minute = 0
        ..isActive = true;
      reminderMorning.medicine.value = med;
      await reminderRepository.saveReminderTime(reminderMorning);

      final reminderEvening = ReminderTime()
        ..hour = 20
        ..minute = 0
        ..isActive = true;
      reminderEvening.medicine.value = med;
      await reminderRepository.saveReminderTime(reminderEvening);

      med.reminders.addAll([reminderMorning, reminderEvening]);
      await medicineRepository.updateMedicine(med);

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await viewModel.loadTodayTimeline(date: testDate);

      expect(viewModel.state, equals(ViewState.idle));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.isEmpty, isFalse);
      expect(viewModel.isSuccess, isTrue);
      expect(viewModel.activeMedicines.length, equals(1));
      expect(viewModel.timelineItems.length, equals(2));

      expect(viewModel.timelineItems[0].scheduledTime.hour, equals(8));
      expect(viewModel.timelineItems[0].timeSlot, equals(TimeSlot.morning));
      expect(viewModel.timelineItems[0].status, equals(MedicineStatus.pending));

      expect(viewModel.timelineItems[1].scheduledTime.hour, equals(20));
      expect(viewModel.timelineItems[1].timeSlot, equals(TimeSlot.evening));
      expect(viewModel.timelineItems[1].status, equals(MedicineStatus.pending));
    });

    test('Empty Dashboard: Correct empty state when no medications exist', () async {
      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await viewModel.loadTodayTimeline(date: DateTime(2026, 8, 28));

      expect(viewModel.state, equals(ViewState.idle));
      expect(viewModel.isEmpty, isTrue);
      expect(viewModel.timelineItems, isEmpty);
      expect(viewModel.totalDosesCount, equals(0));
      expect(viewModel.adherenceRate, equals(0.0));
    });

    test('Segments timeline items accurately into time slots', () async {
      final testDate = DateTime(2026, 8, 28);
      final med = Medicine()
        ..name = 'MultiSlot Med'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med);

      final rMorning = ReminderTime()..hour = 7..minute = 30..isActive = true;
      final rAfternoon = ReminderTime()..hour = 13..minute = 0..isActive = true;
      final rEvening = ReminderTime()..hour = 19..minute = 15..isActive = true;
      final rNight = ReminderTime()..hour = 23..minute = 30..isActive = true;

      for (final r in [rMorning, rAfternoon, rEvening, rNight]) {
        r.medicine.value = med;
        await reminderRepository.saveReminderTime(r);
      }
      med.reminders.addAll([rMorning, rAfternoon, rEvening, rNight]);
      await medicineRepository.updateMedicine(med);

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await viewModel.loadTodayTimeline(date: testDate);

      expect(viewModel.morningDoses.length, equals(1));
      expect(viewModel.afternoonDoses.length, equals(1));
      expect(viewModel.eveningDoses.length, equals(1));
      expect(viewModel.nightDoses.length, equals(1));
    });

    test('markAsTaken updates DoseLog and decrements stock in real repository', () async {
      final testDate = DateTime(2026, 8, 28);
      final med = Medicine()
        ..name = 'Amoxicillin'
        ..dosageValue = 250
        ..currentStock = 10
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med);

      final reminder = ReminderTime()..hour = 9..minute = 0..isActive = true;
      reminder.medicine.value = med;
      await reminderRepository.saveReminderTime(reminder);
      med.reminders.add(reminder);
      await medicineRepository.updateMedicine(med);

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await viewModel.loadTodayTimeline(date: testDate);
      final item = viewModel.timelineItems.first;

      final takeTime = DateTime(2026, 8, 28, 9, 2);
      await viewModel.markAsTaken(item, actualTakenDateTime: takeTime);

      expect(viewModel.timelineItems.first.isTaken, isTrue);
      expect(viewModel.takenDosesCount, equals(1));

      final allLogs = await doseLogRepository.getAllDoseLogs();
      expect(allLogs.length, equals(1));
      expect(allLogs.first.status, equals(MedicineStatus.taken));

      final updatedMed = await medicineRepository.getMedicine(med.id);
      expect(updatedMed!.currentStock, equals(9));
    });

    test('skipDose saves skipped status with reason and updates adherence rate', () async {
      final testDate = DateTime(2026, 8, 28);
      final med = Medicine()
        ..name = 'Ibuprofen'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med);

      final reminder = ReminderTime()..hour = 14..minute = 0..isActive = true;
      reminder.medicine.value = med;
      await reminderRepository.saveReminderTime(reminder);
      med.reminders.add(reminder);
      await medicineRepository.updateMedicine(med);

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await viewModel.loadTodayTimeline(date: testDate);
      final item = viewModel.timelineItems.first;

      await viewModel.skipDose(item, reason: 'Doctor Advised', notes: 'Fasting today');

      expect(viewModel.timelineItems.first.isSkipped, isTrue);
      expect(viewModel.skippedDosesCount, equals(1));

      final allLogs = await doseLogRepository.getAllDoseLogs();
      expect(allLogs.length, equals(1));
      expect(allLogs.first.status, equals(MedicineStatus.skipped));
      expect(allLogs.first.skipReason, equals('Doctor Advised'));
    });

    test('Handles error state gracefully when repository fails', () async {
      await databaseService.close();

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await viewModel.loadTodayTimeline();

      expect(viewModel.state, equals(ViewState.error));
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, isNotNull);
    });
  });
}
