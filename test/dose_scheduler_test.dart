import 'package:flutter_test/flutter_test.dart';
import 'package:pill_reminder_app/core/domain/dose_scheduler.dart';
import 'package:pill_reminder_app/core/enums/frequency_type.dart';
import 'package:pill_reminder_app/core/models/medicine.dart';

void main() {
  group('DoseScheduler Tests', () {
    const scheduler = DoseScheduler();

    test('isMedicineActiveOnDate correctly identifies active daily medicine', () {
      final med = Medicine()
        ..name = 'Daily Med'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1)
        ..isOngoing = true;

      expect(scheduler.isMedicineActiveOnDate(med, DateTime(2026, 8, 28)), isTrue);
      expect(scheduler.isMedicineActiveOnDate(med, DateTime(2026, 7, 31)), isFalse); // Before start date
    });

    test('isMedicineActiveOnDate evaluates course start and end dates', () {
      final med = Medicine()
        ..name = 'Antibiotic'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 10)
        ..endDate = DateTime(2026, 8, 20)
        ..isOngoing = false;

      expect(scheduler.isMedicineActiveOnDate(med, DateTime(2026, 8, 9)), isFalse);
      expect(scheduler.isMedicineActiveOnDate(med, DateTime(2026, 8, 10)), isTrue);
      expect(scheduler.isMedicineActiveOnDate(med, DateTime(2026, 8, 15)), isTrue);
      expect(scheduler.isMedicineActiveOnDate(med, DateTime(2026, 8, 20)), isTrue);
      expect(scheduler.isMedicineActiveOnDate(med, DateTime(2026, 8, 21)), isFalse);
    });

    test('isMedicineActiveOnDate evaluates specific days of week', () {
      final med = Medicine()
        ..name = 'MWF Med'
        ..frequency = FrequencyType.specificDays
        ..specificDaysOfWeek = [DateTime.monday, DateTime.wednesday, DateTime.friday]
        ..startDate = DateTime(2026, 8, 1);

      final friday = DateTime(2026, 8, 28); // Friday (weekday 5)
      final saturday = DateTime(2026, 8, 29); // Saturday (weekday 6)
      final monday = DateTime(2026, 8, 31); // Monday (weekday 1)

      expect(scheduler.isMedicineActiveOnDate(med, friday), isTrue);
      expect(scheduler.isMedicineActiveOnDate(med, saturday), isFalse);
      expect(scheduler.isMedicineActiveOnDate(med, monday), isTrue);
    });

    test('filterActiveMedicines filters list accurately', () {
      final med1 = Medicine()
        ..name = 'Active Daily'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 8, 1);

      final med2 = Medicine()
        ..name = 'Future Med'
        ..frequency = FrequencyType.daily
        ..startDate = DateTime(2026, 9, 1);

      final active = scheduler.filterActiveMedicines([med1, med2], DateTime(2026, 8, 28));
      expect(active.length, equals(1));
      expect(active.first.name, equals('Active Daily'));
    });

    test('Date boundary helpers return expected timestamps', () {
      final date = DateTime(2026, 8, 28, 14, 30);
      final startOfDay = scheduler.getStartOfDay(date);
      final endOfDay = scheduler.getEndOfDay(date);

      expect(startOfDay, equals(DateTime(2026, 8, 28, 0, 0, 0, 0)));
      expect(endOfDay, equals(DateTime(2026, 8, 28, 23, 59, 59, 999)));
      expect(scheduler.isSameDay(date, DateTime(2026, 8, 28, 22, 10)), isTrue);
      expect(scheduler.isSameDay(date, DateTime(2026, 8, 29, 0, 0)), isFalse);
    });
  });
}
