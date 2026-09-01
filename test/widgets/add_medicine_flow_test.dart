import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/repositories/reminder_repository.dart';
import 'package:pill_reminder_app/core/services/alarm_service.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/core/services/notification_service.dart';
import 'package:pill_reminder_app/core/services/permission_service.dart';
import 'package:pill_reminder_app/ui/screens/medicine/add_medicine_screen.dart';
import 'package:pill_reminder_app/ui/viewmodels/add_medicine_viewmodel.dart';

class MockNotificationService extends Fake implements NotificationService {
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
  }) async {}

  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> cancelAllNotifications() async {}
}

class MockPermissionService extends Fake implements PermissionService {
  @override
  Future<bool> hasAllRequiredPermissions() async => true;

  @override
  Future<Map<ph.Permission, ph.PermissionStatus>> requestAllRequiredPermissions() async {
    return {
      ph.Permission.notification: ph.PermissionStatus.granted,
      ph.Permission.scheduleExactAlarm: ph.PermissionStatus.granted,
    };
  }
}

Widget _buildTestWrapper(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
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
    tempDir = await Directory.systemTemp.createTemp('isar_add_med_widget_test_');
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

  group('AddMedicineScreen Integration Tests', () {
    testWidgets('Step navigation and validation prevents proceeding with empty fields', (tester) async {
      final viewModel = AddMedicineViewModel(
        medicineRepository: medicineRepository,
        reminderRepository: reminderRepository,
        alarmService: alarmService,
        permissionService: mockPermissionService,
      );

      await tester.pumpWidget(_buildTestWrapper(AddMedicineScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Add Medication'), findsOneWidget);
      expect(find.textContaining('Basic Info'), findsOneWidget);
      expect(find.text('Next Step'), findsOneWidget);

      // Press Next without typing name
      await tester.tap(find.text('Next Step'));
      await tester.pump(const Duration(milliseconds: 100));

      // Should show validation error
      expect(find.text('Please enter a medicine name'), findsOneWidget);
      expect(viewModel.currentStep, equals(0));

      // Fill in valid details
      viewModel.name = 'Amoxicillin';
      viewModel.dosageValue = 500;
      await tester.pump(const Duration(milliseconds: 100));

      // Proceed to step 2
      await tester.tap(find.text('Next Step'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(viewModel.currentStep, equals(1));
      expect(find.textContaining('Intake & Schedule'), findsOneWidget);
    });

    testWidgets('Completing form and tapping Save Medication persists to Isar', (tester) async {
      final viewModel = AddMedicineViewModel(
        medicineRepository: medicineRepository,
        reminderRepository: reminderRepository,
        alarmService: alarmService,
        permissionService: mockPermissionService,
      );

      viewModel.name = 'Crestor';
      viewModel.dosageValue = 10;
      viewModel.setStep(3); // Jump to review step

      await tester.pumpWidget(_buildTestWrapper(AddMedicineScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Save Medication'), findsOneWidget);

      await tester.runAsync(() async {
        await viewModel.saveMedication();
      });
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Isar database has saved entity
      final allMeds = await tester.runAsync(() => medicineRepository.getAllMedicines());
      expect(allMeds!.length, equals(1));
      expect(allMeds.first.name, equals('Crestor'));
    });
  });
}
