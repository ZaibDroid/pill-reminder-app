import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:pill_reminder_app/ui/custom_widgets/empty_state_widget.dart';
import 'package:pill_reminder_app/ui/screens/history/history_screen.dart';
import 'package:pill_reminder_app/ui/screens/history/widgets/history_calendar_strip.dart';
import 'package:pill_reminder_app/ui/screens/history/widgets/history_dose_item_card.dart';
import 'package:pill_reminder_app/ui/screens/history/widgets/history_summary_card.dart';
import 'package:pill_reminder_app/ui/viewmodels/history_viewmodel.dart';

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
    tempDir = await Directory.systemTemp.createTemp('isar_hist_widget_test_');
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

  group('HistoryScreen Integration Tests', () {
    testWidgets('Displays EmptyStateWidget when no doses are recorded for the date', (tester) async {
      final viewModel = HistoryViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      final date = DateTime(2026, 9, 1);
      await tester.runAsync(() async {
        await viewModel.loadHistoryForDate(date);
      });

      await tester.pumpWidget(_buildTestWrapper(HistoryScreen(viewModel: viewModel)));
      await tester.pumpAndSettle();

      expect(find.byType(HistorySummaryCard), findsOneWidget);
      expect(find.byType(HistoryCalendarStrip), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('No History for This Day'), findsOneWidget);
    });

    testWidgets('Renders real history dose items and summary metrics', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final date = DateTime(2026, 9, 1);

      await tester.runAsync(() async {
        final med = Medicine()
          ..name = 'Metformin'
          ..dosageValue = 500
          ..dosageUnit = 'mg'
          ..frequency = FrequencyType.daily
          ..mealType = MealType.withMeal
          ..startDate = DateTime(2026, 8, 1);
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
          ..actualTakenDateTime = DateTime(2026, 9, 1, 8, 10);
        log.medicine.value = med;
        log.reminderTime.value = rem;
        await doseLogRepository.saveDoseLog(log);
      });

      final viewModel = HistoryViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await tester.runAsync(() async {
        await viewModel.loadHistoryForDate(date);
      });

      await tester.pumpWidget(_buildTestWrapper(HistoryScreen(viewModel: viewModel)));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsNothing);
      expect(find.byType(HistoryDoseItemCard), findsOneWidget);
      expect(find.text('Metformin'), findsOneWidget);
      expect(find.text('500.0 mg • daily'), findsOneWidget);
      expect(find.text('Taken at 08:10 AM'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });
  });
}
