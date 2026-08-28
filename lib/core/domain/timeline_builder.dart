import 'package:isar/isar.dart';
import '../enums/medicine_status.dart';
import '../enums/time_slot.dart';
import '../models/dose_log.dart';
import '../models/medicine.dart';
import '../models/timeline_dose_item.dart';

/// Domain class responsible for constructing, sorting, segmenting, and updating timeline items.
class TimelineBuilder {
  const TimelineBuilder();

  /// Builds a chronologically sorted list of [TimelineDoseItem] instances by merging active medicines,
  /// their active reminders, and existing dose logs for the given [date].
  List<TimelineDoseItem> buildTimeline({
    required List<Medicine> activeMedicines,
    required List<DoseLog> doseLogs,
    required DateTime date,
  }) {
    final items = <TimelineDoseItem>[];
    final matchedLogIds = <Id>{};

    for (final med in activeMedicines) {
      final activeReminders = med.reminders.where((r) => r.isActive).toList();

      for (final reminder in activeReminders) {
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          reminder.hour,
          reminder.minute,
        );

        // Find matching dose log for this medicine and reminder/scheduled time
        DoseLog? matchingLog;
        for (final log in doseLogs) {
          final isSameMedicine = log.medicine.value?.id == med.id ||
              (log.medicine.isLoaded && log.medicine.value?.id == med.id);
          final isSameReminder = log.reminderTime.value?.id == reminder.id;
          final isSameTime = log.scheduledDateTime.hour == reminder.hour &&
              log.scheduledDateTime.minute == reminder.minute &&
              _isSameDay(log.scheduledDateTime, date);

          if (isSameMedicine && (isSameReminder || isSameTime)) {
            matchingLog = log;
            matchedLogIds.add(log.id);
            break;
          }
        }

        items.add(
          TimelineDoseItem(
            medicine: med,
            reminderTime: reminder,
            doseLog: matchingLog,
            scheduledTime: scheduledTime,
            status: matchingLog?.status ?? MedicineStatus.pending,
          ),
        );
      }
    }

    // Include standalone dose logs for today that were not matched to an active reminder
    for (final log in doseLogs) {
      if (!matchedLogIds.contains(log.id)) {
        final med = log.medicine.value ??
            activeMedicines.firstWhere(
              (m) => m.id == log.medicine.value?.id,
              orElse: () => Medicine()..name = 'Medication',
            );

        items.add(
          TimelineDoseItem(
            medicine: med,
            reminderTime: log.reminderTime.value,
            doseLog: log,
            scheduledTime: log.scheduledDateTime,
            status: log.status,
          ),
        );
      }
    }

    // Sort chronologically ascending
    items.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return items;
  }

  /// Filters timeline items belonging to a specific [TimeSlot].
  List<TimelineDoseItem> filterBySlot(List<TimelineDoseItem> items, TimeSlot slot) {
    return items.where((item) => item.timeSlot == slot).toList();
  }

  /// Groups timeline items into a map keyed by [TimeSlot].
  Map<TimeSlot, List<TimelineDoseItem>> groupTimelineBySlot(List<TimelineDoseItem> items) {
    return {
      TimeSlot.morning: filterBySlot(items, TimeSlot.morning),
      TimeSlot.afternoon: filterBySlot(items, TimeSlot.afternoon),
      TimeSlot.evening: filterBySlot(items, TimeSlot.evening),
      TimeSlot.night: filterBySlot(items, TimeSlot.night),
    };
  }

  /// Immutably updates a specific timeline item in the list with a new status and saved log.
  List<TimelineDoseItem> updateItemInTimeline(
    List<TimelineDoseItem> items,
    TimelineDoseItem targetItem, {
    required MedicineStatus updatedStatus,
    required DoseLog updatedLog,
  }) {
    final index = items.indexWhere((ti) =>
        (ti.doseLog != null && ti.doseLog?.id == targetItem.doseLog?.id && targetItem.doseLog?.id != null) ||
        (ti.medicine.id == targetItem.medicine.id &&
            ti.scheduledTime.hour == targetItem.scheduledTime.hour &&
            ti.scheduledTime.minute == targetItem.scheduledTime.minute));

    if (index == -1) {
      return items;
    }

    final updatedList = List<TimelineDoseItem>.from(items);
    updatedList[index] = items[index].copyWith(
      status: updatedStatus,
      doseLog: updatedLog,
    );
    return updatedList;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
