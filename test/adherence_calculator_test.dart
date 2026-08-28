import 'package:flutter_test/flutter_test.dart';
import 'package:pill_reminder_app/core/domain/adherence_calculator.dart';
import 'package:pill_reminder_app/core/enums/medicine_status.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';
import 'package:pill_reminder_app/core/models/timeline_dose_item.dart';

void main() {
  group('AdherenceCalculator Tests', () {
    const calculator = AdherenceCalculator();
    final med = Medicine()..name = 'Test Med';

    test('Counts statuses accurately', () {
      final items = [
        TimelineDoseItem(
          medicine: med,
          scheduledTime: DateTime(2026, 8, 28, 8, 0),
          status: MedicineStatus.taken,
        ),
        TimelineDoseItem(
          medicine: med,
          scheduledTime: DateTime(2026, 8, 28, 12, 0),
          status: MedicineStatus.skipped,
        ),
        TimelineDoseItem(
          medicine: med,
          scheduledTime: DateTime(2026, 8, 28, 16, 0),
          status: MedicineStatus.missed,
        ),
        TimelineDoseItem(
          medicine: med,
          scheduledTime: DateTime(2026, 8, 28, 20, 0),
          status: MedicineStatus.pending,
        ),
      ];

      expect(calculator.countTaken(items), equals(1));
      expect(calculator.countSkipped(items), equals(1));
      expect(calculator.countMissed(items), equals(1));
      expect(calculator.countPending(items), equals(1));
    });

    test('calculateAdherenceRate adheres to PRD Section 3.2 formula', () {
      // 1. Standard calculation: 2 taken out of 4 scheduled, 0 skipped = 50.0%
      expect(calculator.calculateAdherenceRate(total: 4, taken: 2, skipped: 0), equals(50.0));

      // 2. Skipped doses excluded from denominator: 1 taken out of 4 scheduled, 1 skipped -> 1 / (4 - 1) = 33.3%
      expect(calculator.calculateAdherenceRate(total: 4, taken: 1, skipped: 1), equals(33.3));

      // 3. All doses taken: 3 taken out of 3 scheduled, 0 skipped = 100.0%
      expect(calculator.calculateAdherenceRate(total: 3, taken: 3, skipped: 0), equals(100.0));

      // 4. All doses skipped: 0 taken out of 2 scheduled, 2 skipped -> 100.0% (not penalized)
      expect(calculator.calculateAdherenceRate(total: 2, taken: 0, skipped: 2), equals(100.0));

      // 5. Zero doses scheduled: 0.0%
      expect(calculator.calculateAdherenceRate(total: 0, taken: 0, skipped: 0), equals(0.0));
    });

    test('getMotivationalMessage and calculateSummary provide valid messages', () {
      final summaryEmpty = calculator.calculateSummary([]);
      expect(summaryEmpty.total, equals(0));
      expect(summaryEmpty.adherenceRate, equals(0.0));
      expect(summaryEmpty.motivationalMessage, equals('No medications scheduled for today.'));

      final items = [
        TimelineDoseItem(
          medicine: med,
          scheduledTime: DateTime(2026, 8, 28, 8, 0),
          status: MedicineStatus.taken,
        ),
        TimelineDoseItem(
          medicine: med,
          scheduledTime: DateTime(2026, 8, 28, 12, 0),
          status: MedicineStatus.taken,
        ),
      ];

      final summaryAllTaken = calculator.calculateSummary(items);
      expect(summaryAllTaken.total, equals(2));
      expect(summaryAllTaken.taken, equals(2));
      expect(summaryAllTaken.adherenceRate, equals(100.0));
      expect(summaryAllTaken.motivationalMessage, contains('Great job'));
    });
  });
}
