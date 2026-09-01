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
import 'package:pill_reminder_app/ui/screens/reports/reports_screen.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/adherence_heatmap_calendar.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/adherence_metrics_grid.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/dose_distribution_chart.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/export_report_button.dart';
import 'package:pill_reminder_app/ui/screens/reports/widgets/reports_header.dart';
import 'package:pill_reminder_app/ui/viewmodels/reports_viewmodel.dart';

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
    tempDir = await Directory.systemTemp.createTemp('isar_rep_widget_test_');
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

  group('ReportsScreen Integration Tests', () {
    testWidgets('Renders all report sections and metrics', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final month = DateTime(2026, 9, 1);

      await tester.runAsync(() async {
        final med = Medicine()
          ..name = 'Lipitor'
          ..dosageValue = 20
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
      });

      final viewModel = ReportsViewModel(
        medicineRepository: medicineRepository,
        doseLogRepository: doseLogRepository,
      );

      await tester.runAsync(() async {
        await viewModel.loadMonthlyReports(month: month);
      });

      await tester.pumpWidget(_buildTestWrapper(ReportsScreen(viewModel: viewModel)));
      await tester.pumpAndSettle();

      expect(find.byType(ReportsHeader, skipOffstage: false), findsOneWidget);
      expect(find.byType(DoseDistributionChart, skipOffstage: false), findsOneWidget);
      expect(find.byType(AdherenceMetricsGrid, skipOffstage: false), findsOneWidget);
      expect(find.byType(AdherenceHeatmapCalendar, skipOffstage: false), findsOneWidget);
      expect(find.byType(ExportReportButton, skipOffstage: false), findsOneWidget);
      expect(find.text('Export Health Report (PDF)', skipOffstage: false), findsOneWidget);
      expect(find.text('Overall Adherence', skipOffstage: false), findsOneWidget);
      expect(find.text('Monthly Overview', skipOffstage: false), findsOneWidget);
    });
  });
}
