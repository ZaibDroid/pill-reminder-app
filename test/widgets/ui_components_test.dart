import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pill_reminder_app/core/enums/meal_type.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/reminder_time.dart';
import 'package:pill_reminder_app/core/models/timeline_dose_item.dart';
import 'package:pill_reminder_app/ui/custom_widgets/app_bottom_nav_bar.dart';
import 'package:pill_reminder_app/ui/custom_widgets/progress_ring.dart';
import 'package:pill_reminder_app/ui/custom_widgets/status_badge.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/widgets/adherence_card.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/widgets/date_selector.dart';
import 'package:pill_reminder_app/ui/screens/dashboard/widgets/dose_timeline_card.dart';

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
  group('ProgressRing Widget Tests', () {
    testWidgets('Renders progress percentage text correctly', (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(const ProgressRing(percentage: 75)),
      );
      await tester.pumpAndSettle();

      expect(find.text('75%'), findsOneWidget);
    });
  });

  group('StatusBadge Widget Tests', () {
    testWidgets('Renders taken badge with checkmark icon', (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(StatusBadge.fromMedicineStatus(MedicineStatus.taken)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Taken'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Renders missed badge with cancel icon', (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(StatusBadge.fromMedicineStatus(MedicineStatus.missed)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Missed'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });
  });

  group('DateSelector Widget Tests', () {
    testWidgets('Renders horizontal day items and today shortcut', (tester) async {
      DateTime selected = DateTime.now();

      await tester.pumpWidget(
        _buildTestWrapper(
          DateSelector(
            selectedDate: selected,
            onDateSelected: (d) => selected = d,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });
  });

  group('AdherenceCard Widget Tests', () {
    testWidgets('Renders adherence percentage and motivational text', (tester) async {
      await tester.pumpWidget(
        _buildTestWrapper(
          const AdherenceCard(
            adherenceRate: 50.0,
            takenDoses: 2,
            totalDoses: 4,
            motivationalMessage: 'Great job today!',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Today's Adherence"), findsOneWidget);
      expect(find.text('Great job today!'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });
  });

  group('DoseTimelineCard Widget Tests', () {
    testWidgets('Renders pending dose card with action buttons', (tester) async {
      final med = Medicine()
        ..name = 'Amoxicillin'
        ..dosageValue = 500
        ..dosageUnit = 'mg'
        ..mealType = MealType.afterMeal;

      final reminder = ReminderTime()
        ..hour = 8
        ..minute = 0;

      final item = TimelineDoseItem(
        medicine: med,
        reminderTime: reminder,
        scheduledTime: DateTime.now(),
        status: MedicineStatus.pending,
      );

      bool tookDose = false;
      bool skippedDose = false;

      await tester.pumpWidget(
        _buildTestWrapper(
          DoseTimelineCard(
            item: item,
            onTakeDose: () => tookDose = true,
            onSkipDose: () => skippedDose = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Amoxicillin'), findsOneWidget);
      expect(find.text('Take Dose'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Take Dose'));
      expect(tookDose, isTrue);

      await tester.tap(find.text('Skip'));
      expect(skippedDose, isTrue);
    });
  });

  group('AppBottomNavBar Widget Tests', () {
    testWidgets('Renders all 4 navigation tabs', (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: selectedTab,
                onTabSelected: (index) => selectedTab = index,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Reports'));
      expect(selectedTab, equals(2));
    });
  });
}
