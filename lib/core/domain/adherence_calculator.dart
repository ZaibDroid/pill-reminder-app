import '../enums/medicine_status.dart';
import '../models/timeline_dose_item.dart';

/// Immutable summary of adherence metrics and motivational messaging for a given day.
class AdherenceSummary {
  final int total;
  final int taken;
  final int skipped;
  final int missed;
  final int pending;
  final double adherenceRate;
  final String motivationalMessage;

  const AdherenceSummary({
    required this.total,
    required this.taken,
    required this.skipped,
    required this.missed,
    required this.pending,
    required this.adherenceRate,
    required this.motivationalMessage,
  });
}

/// Domain class responsible for calculating adherence metrics and generating motivational guidance.
class AdherenceCalculator {
  const AdherenceCalculator();

  /// Counts the total number of taken doses.
  int countTaken(List<TimelineDoseItem> items) =>
      items.where((item) => item.status == MedicineStatus.taken).length;

  /// Counts the total number of intentionally skipped doses.
  int countSkipped(List<TimelineDoseItem> items) =>
      items.where((item) => item.status == MedicineStatus.skipped).length;

  /// Counts the total number of missed doses.
  int countMissed(List<TimelineDoseItem> items) =>
      items.where((item) => item.status == MedicineStatus.missed).length;

  /// Counts the total number of pending doses.
  int countPending(List<TimelineDoseItem> items) =>
      items.where((item) => item.status == MedicineStatus.pending).length;

  /// Calculates the true adherence percentage as defined in PRD Section 3.2:
  /// Adherence Rate (%) = (Taken Doses / (Total Scheduled Doses - Skipped Doses)) * 100
  double calculateAdherenceRate({
    required int total,
    required int taken,
    required int skipped,
  }) {
    final effectiveScheduled = total - skipped;
    if (effectiveScheduled <= 0) {
      return (total > 0 && skipped == total) || taken > 0 ? 100.0 : 0.0;
    }
    final rate = (taken / effectiveScheduled) * 100.0;
    return double.parse(rate.toStringAsFixed(1));
  }

  /// Produces clinical / humanist motivational copy according to PRD Section 8.3.
  String getMotivationalMessage({
    required int total,
    required int taken,
    required int skipped,
    required int missed,
    required int pending,
    required double adherenceRate,
  }) {
    if (total == 0) {
      return 'No medications scheduled for today.';
    }
    if (taken == total) {
      return "Great job! You've taken all your medications today!";
    }
    if (adherenceRate >= 100.0 && pending == 0) {
      return "Great job! You're on track today.";
    }
    if (taken > 0 && pending > 0) {
      return "Great progress! Keep going with your remaining doses.";
    }
    if (missed > 0 && pending == 0) {
      return "You have missed doses today. Stay consistent tomorrow!";
    }
    return "Stay healthy! Remember to take your scheduled doses.";
  }

  /// Calculates a complete [AdherenceSummary] from a list of timeline items.
  AdherenceSummary calculateSummary(List<TimelineDoseItem> items) {
    final total = items.length;
    final taken = countTaken(items);
    final skipped = countSkipped(items);
    final missed = countMissed(items);
    final pending = countPending(items);
    final rate = calculateAdherenceRate(total: total, taken: taken, skipped: skipped);
    final message = getMotivationalMessage(
      total: total,
      taken: taken,
      skipped: skipped,
      missed: missed,
      pending: pending,
      adherenceRate: rate,
    );

    return AdherenceSummary(
      total: total,
      taken: taken,
      skipped: skipped,
      missed: missed,
      pending: pending,
      adherenceRate: rate,
      motivationalMessage: message,
    );
  }
}
