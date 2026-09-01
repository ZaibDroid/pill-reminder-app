import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:pill_reminder_app/core/enums/frequency_type.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/repositories/dose_log_repository.dart';
import 'package:pill_reminder_app/core/repositories/medicine_repository.dart';
import 'package:pill_reminder_app/core/repositories/reminder_repository.dart';
import 'package:pill_reminder_app/core/services/database_service.dart';
import 'package:pill_reminder_app/ui/custom_widgets/empty_state_widget.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/home_screen.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/widgets/adherence_card.dart';
import 'package:pill_reminder_app/ui/viewmodels/home_viewmodel.dart';

Widget _buildTestWrapper(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: child,
      ),
      routes: {
        '/add_medicine': (context) => const Scaffold(body: Text('Add Med Screen')),
        '/emergency': (context) => const Scaffold(body: Text('Emergency Screen')),
        '/medicine_details': (context) => const Scaffold(body: Text('Details Screen')),
      },
    ),
  );
}

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
    tempDir = await Directory.systemTemp.createTemp('isar_dash_widget_test_');
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

  group('Dashboard HomeScreen Integration Tests', () {
    testWidgets('Displays EmptyStateWidget when no medications are registered', (tester) async {
      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await tester.runAsync(() async {
        await viewModel.loadTodayTimeline(date: DateTime.now());
      });

      await tester.pumpWidget(_buildTestWrapper(HomeScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AdherenceCard), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No Medications Today'), findsOneWidget);
      expect(find.text('Add Medication'), findsWidgets);
    });

    testWidgets('Renders timeline doses, allows marking as taken, and updates adherence', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final today = DateTime.now();

      await tester.runAsync(() async {
        // Seed a medicine with morning reminder
        final med = Medicine()
          ..name = 'Lisinopril'
          ..dosageValue = 10.0
          ..dosageUnit = 'mg'
          ..mealType = MealType.afterMeal
          ..frequency = FrequencyType.daily
          ..currentStock = 20
          ..startDate = today.subtract(const Duration(days: 2));
        await medicineRepository.saveMedicine(med);

        final reminder = ReminderTime()
          ..hour = 8
          ..minute = 0
          ..isActive = true;
        reminder.medicine.value = med;
        await reminderRepository.saveReminderTime(reminder);
        med.reminders.add(reminder);
        await medicineRepository.updateMedicine(med);
      });

      final viewModel = HomeViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await tester.runAsync(() async {
        await viewModel.loadTodayTimeline(date: today);
      });

      await tester.pumpWidget(_buildTestWrapper(HomeScreen(viewModel: viewModel)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(EmptyStateWidget), findsNothing);
      expect(find.text('Lisinopril'), findsOneWidget);
      expect(find.text('Take Dose'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      // Mark Dose as Taken
      await tester.runAsync(() async {
        await viewModel.markAsTaken(viewModel.timelineItems.first);
      });
      await tester.pump(const Duration(milliseconds: 100));

      // Should update to Taken status
      expect(viewModel.timelineItems.first.status, equals(MedicineStatus.taken));
      expect(viewModel.takenDosesCount, equals(1));
      expect(viewModel.adherenceRate, equals(100.0));
    });
  });
}
