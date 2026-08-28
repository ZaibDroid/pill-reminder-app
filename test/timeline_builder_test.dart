import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/domain/timeline_builder.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';
import 'package:pill_reminder_app/core/enums/time_slot.dart';
import 'package:pill_reminder_app/core/models/dose_log.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/models/timeline_dose_item.dart';
import 'package:pill_reminder_app/core/repositories/dose_log_repository.dart';
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/repositories/reminder_repository.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';

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
    tempDir = await Directory.systemTemp.createTemp('isar_timeline_builder_test_');
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

  group('TimelineBuilder Tests', () {
    const builder = TimelineBuilder();
    final testDate = DateTime(2026, 8, 28);

    test('buildTimeline merges medicines, reminders, and logs and sorts chronologically', () async {
      final med = Medicine()..name = 'Aspirin';
      await medicineRepository.saveMedicine(med);

      final r1 = ReminderTime()
        ..hour = 18
        ..minute = 0
        ..isActive = true;
      r1.medicine.value = med;
      await reminderRepository.saveReminderTime(r1);

      final r2 = ReminderTime()
        ..hour = 8
        ..minute = 30
        ..isActive = true;
      r2.medicine.value = med;
      await reminderRepository.saveReminderTime(r2);

      med.reminders.addAll([r1, r2]);
      await medicineRepository.updateMedicine(med);
      await med.reminders.load();

      final logMorning = DoseLog()
        ..scheduledDateTime = DateTime(2026, 8, 28, 8, 30)
        ..status = MedicineStatus.taken
        ..actualTakenDateTime = DateTime(2026, 8, 28, 8, 32);
      logMorning.medicine.value = med;
      logMorning.reminderTime.value = r2;
      await doseLogRepository.saveDoseLog(logMorning);

      final timeline = builder.buildTimeline(
        activeMedicines: [med],
        doseLogs: [logMorning],
        date: testDate,
      );

      expect(timeline.length, equals(2));

      // Sorted chronologically
      expect(timeline[0].scheduledTime.hour, equals(8));
      expect(timeline[0].scheduledTime.minute, equals(30));
      expect(timeline[0].status, equals(MedicineStatus.taken));
      expect(timeline[0].timeSlot, equals(TimeSlot.morning));

      expect(timeline[1].scheduledTime.hour, equals(18));
      expect(timeline[1].scheduledTime.minute, equals(0));
      expect(timeline[1].status, equals(MedicineStatus.pending));
      expect(timeline[1].timeSlot, equals(TimeSlot.evening));
    });

    test('filterBySlot and groupTimelineBySlot segment items accurately', () {
      final med = Medicine()..name = 'Test Med';
      final itemMorning = TimelineDoseItem(
        medicine: med,
        scheduledTime: DateTime(2026, 8, 28, 8, 0),
        status: MedicineStatus.pending,
      );
      final itemAfternoon = TimelineDoseItem(
        medicine: med,
        scheduledTime: DateTime(2026, 8, 28, 14, 0),
        status: MedicineStatus.pending,
      );
      final itemEvening = TimelineDoseItem(
        medicine: med,
        scheduledTime: DateTime(2026, 8, 28, 19, 0),
        status: MedicineStatus.pending,
      );
      final itemNight = TimelineDoseItem(
        medicine: med,
        scheduledTime: DateTime(2026, 8, 28, 23, 0),
        status: MedicineStatus.pending,
      );

      final items = [itemMorning, itemAfternoon, itemEvening, itemNight];

      expect(builder.filterBySlot(items, TimeSlot.morning).length, equals(1));
      expect(builder.filterBySlot(items, TimeSlot.afternoon).length, equals(1));
      expect(builder.filterBySlot(items, TimeSlot.evening).length, equals(1));
      expect(builder.filterBySlot(items, TimeSlot.night).length, equals(1));

      final grouped = builder.groupTimelineBySlot(items);
      expect(grouped[TimeSlot.morning]!.first.scheduledTime.hour, equals(8));
      expect(grouped[TimeSlot.afternoon]!.first.scheduledTime.hour, equals(14));
      expect(grouped[TimeSlot.evening]!.first.scheduledTime.hour, equals(19));
      expect(grouped[TimeSlot.night]!.first.scheduledTime.hour, equals(23));
    });

    test('updateItemInTimeline immutably updates item status and doseLog', () {
      final med = Medicine()..name = 'Test Med';
      final item = TimelineDoseItem(
        medicine: med,
        scheduledTime: DateTime(2026, 8, 28, 9, 0),
        status: MedicineStatus.pending,
      );

      final items = [item];
      final newLog = DoseLog()
        ..scheduledDateTime = DateTime(2026, 8, 28, 9, 0)
        ..status = MedicineStatus.taken;

      final updated = builder.updateItemInTimeline(
        items,
        item,
        updatedStatus: MedicineStatus.taken,
        updatedLog: newLog,
      );

      expect(identical(items, updated), isFalse);
      expect(updated.first.status, equals(MedicineStatus.taken));
      expect(updated.first.isTaken, isTrue);
      expect(updated.first.doseLog, equals(newLog));
    });
  });
}
