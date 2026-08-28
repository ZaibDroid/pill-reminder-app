import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/core/enums/frequency_type.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';
import 'package:pill_reminder_app/core/enums/view_state.dart';
import 'package:pill_reminder_app/core/models/dose_log.dart';
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

      // Create medicine with 2 reminders (Morning 08:00 and Evening 20:00)
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

      // Sorted chronologically
      expect(viewModel.timelineItems[0].scheduledTime.hour, equals(8));
      expect(viewModel.timelineItems[0].timeSlot, equals(TimeSlot.morning));
      expect(viewModel.timelineItems[0].status, equals(MedicineStatus.pending));

      expect(viewModel.timelineItems[1].scheduledTime.hour, equals(20));
      expect(viewModel.timelineItems[1].timeSlot, equals(TimeSlot.evening));
      expect(viewModel.timelineItems[1].status, equals(MedicineStatus.pending));
    });

    test('Filters inactive medicines based on startDate, endDate, and frequency', () async {
      final targetDate = DateTime(2026, 8, 28); // Friday (weekday 5)

      // 1. Future medicine (should be excluded)
      final futureMed = Medicine()
        ..name = 'Future Med'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 9, 1);
      await medicineRepository.saveMedicine(futureMed);

      // 2. Expired course medicine (should be excluded)
      final expiredMed = Medicine()
        ..name = 'Expired Med'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1)
        ..endDate = DateTime(2026, 8, 20)
        ..isOngoing = false;
      await medicineRepository.saveMedicine(expiredMed);

      // 3. Specific days medicine for Saturday/Sunday (weekday 6, 7) (should be excluded on Friday)
      final weekendMed = Medicine()
        ..name = 'Weekend Med'
        ..frequency = FrequencyType.specificDays
        ..specificDaysOfWeek = [DateTime.saturday, DateTime.sunday]
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(weekendMed);

      // 4. Specific days medicine for Friday (weekday 5) (should be included)
      final fridayMed = Medicine()
        ..name = 'Friday Med'
        ..frequency = FrequencyType.specificDays
        ..specificDaysOfWeek = [DateTime.friday]
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(fridayMed);

      final r = ReminderTime()..hour = 9..minute = 0..isActive = true;
      r.medicine.value = fridayMed;
      await reminderRepository.saveReminderTime(r);
      fridayMed.reminders.add(r);
      await medicineRepository.updateMedicine(fridayMed);

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await viewModel.loadTodayTimeline(date: targetDate);

      expect(viewModel.activeMedicines.length, equals(1));
      expect(viewModel.activeMedicines.first.name, equals('Friday Med'));
      expect(viewModel.timelineItems.length, equals(1));
    });

    test('Segments timeline items accurately into morning, afternoon, evening, and night slots', () async {
      final testDate = DateTime(2026, 8, 28);
      final med = Medicine()
        ..name = 'MultiSlot Med'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med);

      // Reminders in 4 slots
      final rMorning = ReminderTime()..hour = 7..minute = 30..isActive = true; // Morning (05:00 - 11:59)
      final rAfternoon = ReminderTime()..hour = 13..minute = 0..isActive = true; // Afternoon (12:00 - 16:59)
      final rEvening = ReminderTime()..hour = 19..minute = 15..isActive = true; // Evening (17:00 - 21:59)
      final rNight = ReminderTime()..hour = 23..minute = 30..isActive = true; // Night (22:00 - 04:59)

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
      expect(viewModel.morningDoses.first.scheduledTime.hour, equals(7));

      expect(viewModel.afternoonDoses.length, equals(1));
      expect(viewModel.afternoonDoses.first.scheduledTime.hour, equals(13));

      expect(viewModel.eveningDoses.length, equals(1));
      expect(viewModel.eveningDoses.first.scheduledTime.hour, equals(19));

      expect(viewModel.nightDoses.length, equals(1));
      expect(viewModel.nightDoses.first.scheduledTime.hour, equals(23));

      final grouped = viewModel.groupedTimelineItems;
      expect(grouped[TimeSlot.morning]!.length, equals(1));
      expect(grouped[TimeSlot.afternoon]!.length, equals(1));
      expect(grouped[TimeSlot.evening]!.length, equals(1));
      expect(grouped[TimeSlot.night]!.length, equals(1));
    });

    test('Adherence calculations comply with PRD formula and handle skipped doses', () async {
      final testDate = DateTime(2026, 8, 28);
      final med = Medicine()
        ..name = 'Adherence Med'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med);

      // 4 doses scheduled
      final r1 = ReminderTime()..hour = 8..minute = 0..isActive = true;
      final r2 = ReminderTime()..hour = 12..minute = 0..isActive = true;
      final r3 = ReminderTime()..hour = 16..minute = 0..isActive = true;
      final r4 = ReminderTime()..hour = 20..minute = 0..isActive = true;

      for (final r in [r1, r2, r3, r4]) {
        r.medicine.value = med;
        await reminderRepository.saveReminderTime(r);
      }
      med.reminders.addAll([r1, r2, r3, r4]);
      await medicineRepository.updateMedicine(med);

      // Dose 1 is Taken
      final log1 = DoseLog()
        ..scheduledDateTime = DateTime(2026, 8, 28, 8, 0)
        ..status = MedicineStatus.taken
        ..actualTakenDateTime = DateTime(2026, 8, 28, 8, 5);
      log1.medicine.value = med;
      log1.reminderTime.value = r1;
      await doseLogRepository.saveDoseLog(log1);

      // Dose 2 is Skipped
      final log2 = DoseLog()
        ..scheduledDateTime = DateTime(2026, 8, 28, 12, 0)
        ..status = MedicineStatus.skipped
        ..skipReason = 'Nausea';
      log2.medicine.value = med;
      log2.reminderTime.value = r2;
      await doseLogRepository.saveDoseLog(log2);

      // Dose 3 is Missed
      final log3 = DoseLog()
        ..scheduledDateTime = DateTime(2026, 8, 28, 16, 0)
        ..status = MedicineStatus.missed;
      log3.medicine.value = med;
      log3.reminderTime.value = r3;
      await doseLogRepository.saveDoseLog(log3);

      // Dose 4 is Pending (no log saved yet)

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await viewModel.loadTodayTimeline(date: testDate);

      expect(viewModel.totalDosesCount, equals(4));
      expect(viewModel.takenDosesCount, equals(1));
      expect(viewModel.skippedDosesCount, equals(1));
      expect(viewModel.missedDosesCount, equals(1));
      expect(viewModel.pendingDosesCount, equals(1));

      // Formula: (Taken / (Total - Skipped)) * 100 = (1 / (4 - 1)) * 100 = 33.3%
      expect(viewModel.adherenceRate, equals(33.3));
      expect(viewModel.adherenceMotivationalMessage, isNotEmpty);
    });

    test('markAsTaken updates DoseLog, decrements stock, and updates local state', () async {
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
      expect(item.status, equals(MedicineStatus.pending));

      // Mark as taken
      final takeTime = DateTime(2026, 8, 28, 9, 2);
      await viewModel.markAsTaken(item, actualTakenDateTime: takeTime);

      // Verify ViewModel updated immediately
      expect(viewModel.timelineItems.first.isTaken, isTrue);
      expect(viewModel.timelineItems.first.status, equals(MedicineStatus.taken));
      expect(viewModel.takenDosesCount, equals(1));

      // Verify repository / database state
      final allLogs = await doseLogRepository.getAllDoseLogs();
      expect(allLogs.length, equals(1));
      expect(allLogs.first.status, equals(MedicineStatus.taken));
      expect(allLogs.first.actualTakenDateTime, equals(takeTime));

      // Verify stock was decremented
      final updatedMed = await medicineRepository.getMedicine(med.id);
      expect(updatedMed!.currentStock, equals(9));
    });

    test('skipDose saves skipped status with reason and updates local state', () async {
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
      expect(viewModel.timelineItems.first.status, equals(MedicineStatus.skipped));
      expect(viewModel.skippedDosesCount, equals(1));

      final allLogs = await doseLogRepository.getAllDoseLogs();
      expect(allLogs.length, equals(1));
      expect(allLogs.first.status, equals(MedicineStatus.skipped));
      expect(allLogs.first.skipReason, equals('Doctor Advised'));
      expect(allLogs.first.notes, equals('Fasting today'));
    });

    test('markAsMissed updates status to missed', () async {
      final testDate = DateTime(2026, 8, 28);
      final med = Medicine()
        ..name = 'Vitamin D'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med);

      final reminder = ReminderTime()..hour = 10..minute = 0..isActive = true;
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

      await viewModel.markAsMissed(item);

      expect(viewModel.timelineItems.first.isMissed, isTrue);
      expect(viewModel.missedDosesCount, equals(1));

      final allLogs = await doseLogRepository.getAllDoseLogs();
      expect(allLogs.length, equals(1));
      expect(allLogs.first.status, equals(MedicineStatus.missed));
    });

    test('selectDate and refresh update data for different dates', () async {
      final med = Medicine()
        ..name = 'Daily Med'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1);
      await medicineRepository.saveMedicine(med);

      final reminder = ReminderTime()..hour = 8..minute = 0..isActive = true;
      reminder.medicine.value = med;
      await reminderRepository.saveReminderTime(reminder);
      med.reminders.add(reminder);
      await medicineRepository.updateMedicine(med);

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await viewModel.selectDate(tomorrow);

      expect(viewModel.selectedDate.day, equals(tomorrow.day));
      expect(viewModel.timelineItems.length, equals(1));

      // Now refresh
      await viewModel.refresh();
      expect(viewModel.timelineItems.length, equals(1));
    });

    test('Handles error states gracefully when repository fails', () async {
      // Close database to simulate repository failure
      await databaseService.close();

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await viewModel.loadTodayTimeline();

      expect(viewModel.state, equals(ViewState.error));
      expect(viewModel.hasError, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('GetIt setupLocator registers HomeViewModel factory', () {
      if (locator.isRegistered<HomeViewModel>()) {
        locator.unregister<HomeViewModel>();
      }
      setupLocator();

      expect(locator.isRegistered<HomeViewModel>(), isTrue);
      final vm1 = locator<HomeViewModel>();
      final vm2 = locator<HomeViewModel>();

      // Since registered as factory, instances should be distinct
      expect(identical(vm1, vm2), isFalse);
    });
  });
}
