import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:pill_reminder_app/core/enums/frequency_type.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/enums/view_state.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/repositories/reminder_repository.dart';
import 'package:pill_reminder_app/core/services/alarm_service.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/core/services/notification_service.dart';
import 'package:pill_reminder_app/core/services/permission_service.dart';
import 'package:pill_reminder_app/ui/viewmodels/add_medicine_viewmodel.dart';

class MockNotificationService extends Fake implements NotificationService {
  final List<Map<String, dynamic>> scheduledCalls = [];

  @override
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    String? sound,
    bool enableVibration = true,
  }) async {
    scheduledCalls.add({
      'type': 'daily',
      'id': id,
      'title': title,
      'body': body,
      'hour': hour,
      'minute': minute,
      'payload': payload,
    });
  }

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> cancelAllNotifications() async {}
}

class MockPermissionService extends Fake implements PermissionService {
  bool hasPermissionsResult = true;
  bool requestedPermissionsCalled = false;

  @override
  Future<bool> hasAllRequiredPermissions() async => hasPermissionsResult;

  @override
  Future<Map<ph.Permission, ph.PermissionStatus>> requestAllRequiredPermissions() async {
    requestedPermissionsCalled = true;
    return {
      ph.Permission.notification: ph.PermissionStatus.granted,
      ph.Permission.scheduleExactAlarm: ph.PermissionStatus.granted,
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseService databaseService;
  late MedicineRepository medicineRepository;
  late ReminderRepository reminderRepository;
  late MockNotificationService mockNotificationService;
  late AlarmService alarmService;
  late MockPermissionService mockPermissionService;
  late Directory tempDir;

  setUpAll(() async {
    HttpOverrides.global = null;
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_add_med_vm_test_');
    databaseService = DatabaseService();
    await databaseService.init(
      directory: tempDir.path,
      name: 'test_db_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    medicineRepository = MedicineRepository(databaseService: databaseService);
    reminderRepository = ReminderRepository(databaseService: databaseService);
    mockNotificationService = MockNotificationService();
    alarmService = AlarmService(notificationService: mockNotificationService);
    mockPermissionService = MockPermissionService();
  });

  tearDown(() async {
    if (databaseService.isOpen) {
      await databaseService.close(deleteFromDisk: true);
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AddMedicineViewModel Tests', () {
    test('Initial step state and step progression validation', () {
      final viewModel = AddMedicineViewModel(
        medicineRepository: medicineRepository,
        reminderRepository: reminderRepository,
        alarmService: alarmService,
        permissionService: mockPermissionService,
      );

      expect(viewModel.currentStep, equals(0));
      expect(viewModel.totalSteps, equals(4));
      expect(viewModel.state, equals(ViewState.idle));
      expect(viewModel.isLoading, isFalse);

      // Cannot advance Step 0 without medicine name
      expect(viewModel.nextStep(), isFalse);
      expect(viewModel.errorMessage, contains('medicine name'));

      viewModel.name = 'Paracetamol';
      viewModel.dosageValue = 500;
      expect(viewModel.nextStep(), isTrue);
      expect(viewModel.currentStep, equals(1));

      // Step 1: Reminder times management
      expect(viewModel.reminderTimes.length, equals(1));
      viewModel.addReminderTime(const TimeOfDay(hour: 20, minute: 0));
      expect(viewModel.reminderTimes.length, equals(2));

      expect(viewModel.nextStep(), isTrue);
      expect(viewModel.currentStep, equals(2));

      expect(viewModel.nextStep(), isTrue);
      expect(viewModel.currentStep, equals(3));

      // Step 3 is review, nextStep won't exceed 3
      expect(viewModel.nextStep(), isFalse);
      expect(viewModel.currentStep, equals(3));

      viewModel.previousStep();
      expect(viewModel.currentStep, equals(2));
    });

    test('Full Save Flow: Persists Medicine + ReminderTime relationship and schedules alarms', () async {
      final viewModel = AddMedicineViewModel(
        medicineRepository: medicineRepository,
        reminderRepository: reminderRepository,
        alarmService: alarmService,
        permissionService: mockPermissionService,
      );

      viewModel.name = 'Atorvastatin';
      viewModel.dosageValue = 20.0;
      viewModel.dosageUnit = 'mg';
      viewModel.formFactor = 'tablet';
      viewModel.mealType = MealType.afterMeal;
      viewModel.frequency = FrequencyType.daily;
      viewModel.currentStock = 60;
      viewModel.lowStockThreshold = 10;
      viewModel.reminderTimes = [
        const TimeOfDay(hour: 8, minute: 30),
        const TimeOfDay(hour: 21, minute: 0),
      ];

      final saveSuccess = await viewModel.saveMedication();

      expect(saveSuccess, isTrue);
      expect(viewModel.state, equals(ViewState.idle));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);

      // 1. Verify Medicine persistence
      final allMeds = await medicineRepository.getAllMedicines();
      expect(allMeds.length, equals(1));
      final savedMed = allMeds.first;
      expect(savedMed.name, equals('Atorvastatin'));
      expect(savedMed.dosageValue, equals(20.0));
      expect(savedMed.currentStock, equals(60));

      // 2. Verify ReminderTime persistence
      final allReminders = await reminderRepository.getAllReminderTimes();
      expect(allReminders.length, equals(2));
      expect(allReminders[0].hour, equals(8));
      expect(allReminders[0].minute, equals(30));
      expect(allReminders[1].hour, equals(21));
      expect(allReminders[1].minute, equals(0));

      // 3. Verify Medicine ↔ Reminder bidirectional Isar relationship
      await savedMed.reminders.load();
      expect(savedMed.reminders.length, equals(2));
      expect(savedMed.reminders.map((r) => r.hour).toSet(), containsAll([8, 21]));

      await allReminders[0].medicine.load();
      expect(allReminders[0].medicine.value?.name, equals('Atorvastatin'));

      // 4. Verify Notification / Alarm scheduling delegation
      expect(mockNotificationService.scheduledCalls.length, equals(2));
      expect(mockNotificationService.scheduledCalls[0]['title'], contains('Atorvastatin'));
      expect(mockNotificationService.scheduledCalls[0]['hour'], equals(8));
      expect(mockNotificationService.scheduledCalls[0]['minute'], equals(30));
    });

    test('Permission Handling: Requests missing permissions prior to scheduling', () async {
      mockPermissionService.hasPermissionsResult = false;

      final viewModel = AddMedicineViewModel(
        medicineRepository: medicineRepository,
        reminderRepository: reminderRepository,
        alarmService: alarmService,
        permissionService: mockPermissionService,
      );

      viewModel.name = 'Lisinopril';
      viewModel.dosageValue = 10;
      viewModel.reminderTimes = [const TimeOfDay(hour: 9, minute: 0)];

      final success = await viewModel.saveMedication();

      expect(success, isTrue);
      expect(mockPermissionService.requestedPermissionsCalled, isTrue);
      expect(mockNotificationService.scheduledCalls.length, equals(1));
    });

    test('Save Failure Handling: Transitions to error state and sets errorMessage gracefully', () async {
      // Close database to trigger save failure
      await databaseService.close();

      final viewModel = AddMedicineViewModel(
        medicineRepository: medicineRepository,
        reminderRepository: reminderRepository,
        alarmService: alarmService,
        permissionService: mockPermissionService,
      );

      viewModel.name = 'Metoprolol';
      viewModel.dosageValue = 50;

      final success = await viewModel.saveMedication();

      expect(success, isFalse);
      expect(viewModel.state, equals(ViewState.error));
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('Editing existing medicine updates fields without duplicate entries', () async {
      // Seed an existing medicine
      final existingMed = Medicine()
        ..name = 'Old Name'
        ..dosageValue = 5
        ..dosageUnit = 'mg'
        ..mealType = MealType.beforeMeal;
      await medicineRepository.saveMedicine(existingMed);

      final viewModel = AddMedicineViewModel(
        medicineRepository: medicineRepository,
        reminderRepository: reminderRepository,
        alarmService: alarmService,
        permissionService: mockPermissionService,
        existingMedicine: existingMed,
      );

      expect(viewModel.isEditing, isTrue);
      expect(viewModel.name, equals('Old Name'));

      viewModel.name = 'Updated Name';
      viewModel.dosageValue = 15;
      viewModel.reminderTimes = [const TimeOfDay(hour: 7, minute: 0)];

      final success = await viewModel.saveMedication();

      expect(success, isTrue);

      final allMeds = await medicineRepository.getAllMedicines();
      expect(allMeds.length, equals(1));
      expect(allMeds.first.name, equals('Updated Name'));
      expect(allMeds.first.dosageValue, equals(15));
    });
  });
}
