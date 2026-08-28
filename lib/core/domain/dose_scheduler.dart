import '../enums/frequency_type.dart';
import '../models/medicine.dart';

/// Domain class responsible for determining which medicines are scheduled and active for a given date.
class DoseScheduler {
  const DoseScheduler();

  /// Filters a list of medicines to return only those active on [date].
  List<Medicine> filterActiveMedicines(List<Medicine> medicines, DateTime date) {
    return medicines.where((med) => isMedicineActiveOnDate(med, date)).toList();
  }

  /// Checks if a single [Medicine] entity is active and scheduled for [date].
  bool isMedicineActiveOnDate(Medicine medicine, DateTime date) {
    final startOfTargetDate = DateTime(date.year, date.month, date.day);
    final startOfMedDate = DateTime(
      medicine.startDate.year,
      medicine.startDate.month,
      medicine.startDate.day,
    );

    // 1. Check if course has started
    if (startOfTargetDate.isBefore(startOfMedDate)) {
      return false;
    }

    // 2. Check if course has ended (for non-ongoing medications)
    if (!medicine.isOngoing && medicine.endDate != null) {
      final endOfMedDate = DateTime(
        medicine.endDate!.year,
        medicine.endDate!.month,
        medicine.endDate!.day,
        23,
        59,
        59,
      );
      if (startOfTargetDate.isAfter(endOfMedDate)) {
        return false;
      }
    }

    // 3. Evaluate frequency rules
    switch (medicine.frequency) {
      case FrequencyType.daily:
      case FrequencyType.interval:
        return true;
      case FrequencyType.specificDays:
        return medicine.specificDaysOfWeek.contains(date.weekday);
    }
  }

  /// Returns the start boundary (00:00:00.000) for a given [date].
  DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  /// Returns the end boundary (23:59:59.999) for a given [date].
  DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Evaluates whether two dates represent the exact same calendar day.
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
