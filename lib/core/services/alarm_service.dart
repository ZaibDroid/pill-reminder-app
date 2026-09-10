import 'dart:convert';
import '../../app/locator.dart';
import '../enums/frequency_type.dart';
import '../enums/meal_type.dart';
import '../models/medicine.dart';
import '../models/reminder_time.dart';
import '../repositories/medicine_repository.dart';
import '../utils/custom_logger.dart';
import 'notification_service.dart';

/// Offline-first service for managing medication alarms and reminder scheduling in MediAlert.
/// Coordinates directly with [NotificationService] to trigger scheduled audio/visual alarms.
class AlarmService {
  final log = CustomLogger(className: '@AlarmService');

  final NotificationService _notificationService;

  AlarmService({NotificationService? notificationService})
      : _notificationService = notificationService ??
            (locator.isRegistered<NotificationService>()
                ? locator<NotificationService>()
                : NotificationService());

  /// Exposes the underlying [NotificationService].
  NotificationService get notificationService => _notificationService;

  /// Returns user-friendly meal guidance string for a given [MealType].
  String getMealGuidanceText(MealType mealType) {
    switch (mealType) {
      case MealType.beforeMeal:
        return 'Take before food';
      case MealType.afterMeal:
        return 'Take after food';
      case MealType.withMeal:
        return 'Take with food';
      case MealType.noRelation:
        return '';
    }
  }

  /// Formats dosage display string, e.g. "500 mg" or "1.5 Tablet".
  String formatDosage(double dosageValue, String dosageUnit) {
    final formattedValue = dosageValue % 1 == 0
        ? dosageValue.toInt().toString()
        : dosageValue.toString();
    return '$formattedValue $dosageUnit'.trim();
  }

  /// Builds a standard structured notification payload string.
  String buildAlarmPayload({
    required int medicineId,
    required int reminderTimeId,
    int? doseLogId,
  }) {
    final payloadMap = <String, dynamic>{
      'type': 'medication_alarm',
      'medicineId': medicineId,
      'reminderTimeId': reminderTimeId,
    };
    if (doseLogId != null) {
      payloadMap['doseLogId'] = doseLogId;
    }
    return jsonEncode(payloadMap);
  }

  /// Formats notification title for a medication reminder.
  String buildAlarmTitle(Medicine medicine) {
    return 'Time for ${medicine.name}';
  }

  /// Formats notification body with dosage and meal relation guidance.
  String buildAlarmBody(Medicine medicine) {
    final dosage = formatDosage(medicine.dosageValue, medicine.dosageUnit);
    final mealText = getMealGuidanceText(medicine.mealType);

    if (mealText.isNotEmpty) {
      return '$dosage • $mealText';
    }
    return dosage;
  }

  /// Schedules a medication alarm for a specific [reminder] slot.
  /// If the reminder is not active ([ReminderTime.isActive] == false), cancels any existing alarm.
  Future<void> scheduleMedicationAlarm(
    Medicine medicine,
    ReminderTime reminder,
  ) async {
    if (!reminder.isActive) {
      log.d(
        '@scheduleMedicationAlarm: Reminder [ID: ${reminder.id}] is inactive. Cancelling alarm if scheduled.',
      );
      await cancelMedicationAlarm(reminder.id);
      return;
    }

    try {
      final title = buildAlarmTitle(medicine);
      final body = buildAlarmBody(medicine);
      final payload = buildAlarmPayload(
        medicineId: medicine.id,
        reminderTimeId: reminder.id,
      );

      log.i(
        '@scheduleMedicationAlarm: Scheduling alarm for ${medicine.name} at ${reminder.hour}:${reminder.minute.toString().padLeft(2, '0')} (Frequency: ${medicine.frequency.name})',
      );

      switch (medicine.frequency) {
        case FrequencyType.daily:
          await _notificationService.scheduleDailyNotification(
            id: reminder.id,
            title: title,
            body: body,
            hour: reminder.hour,
            minute: reminder.minute,
            payload: payload,
            enableVibration: reminder.isVibrationEnabled,
          );
          break;

        case FrequencyType.specificDays:
        case FrequencyType.interval:
          // For specific days or interval schedules, calculate next occurrence date and schedule
          final nextOccurrence = _calculateNextOccurrence(
            medicine: medicine,
            hour: reminder.hour,
            minute: reminder.minute,
          );
          await _notificationService.scheduleNotification(
            id: reminder.id,
            title: title,
            body: body,
            scheduledDate: nextOccurrence,
            payload: payload,
            enableVibration: reminder.isVibrationEnabled,
          );
          break;
      }

      log.i('@scheduleMedicationAlarm: Successfully scheduled alarm [Reminder ID: ${reminder.id}]');
    } catch (e, stackTrace) {
      log.e(
        '@scheduleMedicationAlarm: Failed to schedule alarm for reminder [ID: ${reminder.id}]',
        e,
        stackTrace,
      );
    }
  }

  /// Schedules all active reminders for a given [medicine].
  Future<void> scheduleAllRemindersForMedicine(
    Medicine medicine,
    List<ReminderTime> reminders,
  ) async {
    try {
      log.i(
        '@scheduleAllRemindersForMedicine: Scheduling ${reminders.length} reminder(s) for medicine "${medicine.name}" [ID: ${medicine.id}]',
      );

      for (final reminder in reminders) {
        await scheduleMedicationAlarm(medicine, reminder);
      }
    } catch (e, stackTrace) {
      log.e(
        '@scheduleAllRemindersForMedicine: Error scheduling reminders for medicine [ID: ${medicine.id}]',
        e,
        stackTrace,
      );
    }
  }

  /// Updates or re-schedules an alarm for a given [medicine] and [reminder].
  Future<void> updateMedicationAlarm(
    Medicine medicine,
    ReminderTime reminder,
  ) async {
    try {
      log.i('@updateMedicationAlarm: Updating alarm for reminder [ID: ${reminder.id}]');
      await cancelMedicationAlarm(reminder.id);
      if (reminder.isActive) {
        await scheduleMedicationAlarm(medicine, reminder);
      }
    } catch (e, stackTrace) {
      log.e(
        '@updateMedicationAlarm: Failed to update alarm for reminder [ID: ${reminder.id}]',
        e,
        stackTrace,
      );
    }
  }

  /// Schedules a single one-off medication dose alarm at [scheduledDateTime].
  Future<void> scheduleOneTimeAlarm({
    required Medicine medicine,
    required ReminderTime reminder,
    required DateTime scheduledDateTime,
    int? doseLogId,
  }) async {
    try {
      log.i(
        '@scheduleOneTimeAlarm: Scheduling one-time alarm for "${medicine.name}" at $scheduledDateTime',
      );

      final title = buildAlarmTitle(medicine);
      final body = buildAlarmBody(medicine);
      final payload = buildAlarmPayload(
        medicineId: medicine.id,
        reminderTimeId: reminder.id,
        doseLogId: doseLogId,
      );

      await _notificationService.scheduleNotification(
        id: reminder.id,
        title: title,
        body: body,
        scheduledDate: scheduledDateTime,
        payload: payload,
        enableVibration: reminder.isVibrationEnabled,
      );

      log.i('@scheduleOneTimeAlarm: Successfully scheduled one-time alarm [ID: ${reminder.id}]');
    } catch (e, stackTrace) {
      log.e(
        '@scheduleOneTimeAlarm: Failed to schedule one-time alarm for reminder [ID: ${reminder.id}]',
        e,
        stackTrace,
      );
    }
  }

  /// Reschedules an alarm for a temporary snooze interval (default 10 minutes).
  Future<void> snoozeAlarm({
    required Medicine medicine,
    required ReminderTime reminder,
    int durationMinutes = 10,
    int? doseLogId,
  }) async {
    try {
      log.i(
        '@snoozeAlarm: Snoozing alarm for "${medicine.name}" for $durationMinutes minutes',
      );

      final snoozeDateTime = DateTime.now().add(Duration(minutes: durationMinutes));
      final title = 'Snoozed: ${medicine.name}';
      final body = buildAlarmBody(medicine);
      final payload = buildAlarmPayload(
        medicineId: medicine.id,
        reminderTimeId: reminder.id,
        doseLogId: doseLogId,
      );

      // Unique ID for snooze alarm to avoid collision with base reminder slot
      final snoozeId = reminder.id + 100000;

      await _notificationService.scheduleNotification(
        id: snoozeId,
        title: title,
        body: body,
        scheduledDate: snoozeDateTime,
        payload: payload,
        enableVibration: reminder.isVibrationEnabled,
      );

      log.i('@snoozeAlarm: Successfully scheduled snooze alarm [ID: $snoozeId] at $snoozeDateTime');
    } catch (e, stackTrace) {
      log.e(
        '@snoozeAlarm: Failed to snooze alarm for reminder [ID: ${reminder.id}]',
        e,
        stackTrace,
      );
    }
  }

  /// Cancels a specific scheduled medication alarm by [reminderId].
  Future<void> cancelMedicationAlarm(int reminderId) async {
    try {
      log.i('@cancelMedicationAlarm: Cancelling alarm for reminder [ID: $reminderId]');
      await _notificationService.cancelNotification(reminderId);
      // Also cancel any associated snooze alarm
      await _notificationService.cancelNotification(reminderId + 100000);
      log.d('@cancelMedicationAlarm: Alarm cancelled [ID: $reminderId]');
    } catch (e, stackTrace) {
      log.e(
        '@cancelMedicationAlarm: Failed to cancel alarm for reminder [ID: $reminderId]',
        e,
        stackTrace,
      );
    }
  }

  /// Cancels all alarms for a list of [reminders].
  Future<void> cancelAlarmsForReminders(List<ReminderTime> reminders) async {
    try {
      log.i(
        '@cancelAlarmsForReminders: Cancelling alarms for ${reminders.length} reminder(s)',
      );
      for (final reminder in reminders) {
        await cancelMedicationAlarm(reminder.id);
      }
    } catch (e, stackTrace) {
      log.e('@cancelAlarmsForReminders: Error cancelling reminder alarms', e, stackTrace);
    }
  }

  /// Cancels all scheduled and active alarms across the application.
  Future<void> cancelAllAlarms() async {
    try {
      log.i('@cancelAllAlarms: Cancelling all medication alarms...');
      await _notificationService.cancelAllNotifications();
      log.i('@cancelAllAlarms: All alarms cancelled successfully');
    } catch (e, stackTrace) {
      log.e('@cancelAllAlarms: Failed to cancel all alarms', e, stackTrace);
    }
  }

  /// Reschedules all active medication alarms from the repository.
  /// Used on startup or settings changes to ensure all medicines are synchronized
  /// with the correct native timezone and notification channels.
  Future<int> rescheduleAllActiveAlarms({MedicineRepository? medicineRepository}) async {
    try {
      final repo = medicineRepository ??
          (locator.isRegistered<MedicineRepository>()
              ? locator<MedicineRepository>()
              : null);

      if (repo == null) {
        log.w('@rescheduleAllActiveAlarms: MedicineRepository not registered, skipping reschedule');
        return 0;
      }

      final medicines = await repo.getAllMedicines();
      int totalRescheduled = 0;

      for (final med in medicines) {
        await med.reminders.load();
        for (final reminder in med.reminders) {
          if (reminder.isActive) {
            await scheduleMedicationAlarm(med, reminder);
            totalRescheduled++;
          }
        }
      }

      log.i(
        '@rescheduleAllActiveAlarms: Successfully synced and rescheduled $totalRescheduled reminder(s) across ${medicines.length} medicine(s)',
      );
      return totalRescheduled;
    } catch (e, stackTrace) {
      log.e('@rescheduleAllActiveAlarms: Error rescheduling active alarms', e, stackTrace);
      return 0;
    }
  }

  /// Triggers an immediate test notification with sound and vibration to verify system alarms.
  Future<void> testAlarm() async {
    try {
      log.i('@testAlarm: Triggering immediate test alarm notification');
      await _notificationService.showNotification(
        id: 999999,
        title: 'MediAlert Alarm Test',
        body: 'Test notification - Sound and vibration are configured and active!',
        enableVibration: true,
      );
    } catch (e, stackTrace) {
      log.e('@testAlarm: Error triggering test alarm', e, stackTrace);
    }
  }

  String? _lastTriggeredSlot;

  /// Checks if any active medication reminder matches the current minute right now.
  /// Used for immediate foreground full-screen alarm trigger when app is open.
  Future<Medicine?> checkForDueMedicineNow() async {
    try {
      final now = DateTime.now();
      final repo = locator.isRegistered<MedicineRepository>()
          ? locator<MedicineRepository>()
          : null;
      if (repo == null) return null;

      final medicines = await repo.getAllMedicines();
      for (final med in medicines) {
        if (!med.isOngoing && med.endDate != null && med.endDate!.isBefore(now)) continue;
        await med.reminders.load();
        for (final reminder in med.reminders) {
          if (reminder.isActive &&
              reminder.hour == now.hour &&
              reminder.minute == now.minute) {
            final slotKey = '${med.id}_${reminder.id}_${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}';
            if (_lastTriggeredSlot == slotKey) {
              return null; // Already triggered for this minute slot
            }
            _lastTriggeredSlot = slotKey;
            log.i('@checkForDueMedicineNow: Found due medication "${med.name}" at $now');
            return med;
          }
        }
      }
    } catch (e) {
      log.d('@checkForDueMedicineNow: Error checking due medicines: $e');
    }
    return null;
  }

  /// Helper to calculate the next target [DateTime] for specific days or interval schedules.
  DateTime _calculateNextOccurrence({
    required Medicine medicine,
    required int hour,
    required int minute,
  }) {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (medicine.frequency == FrequencyType.specificDays &&
        medicine.specificDaysOfWeek.isNotEmpty) {
      // Find the next day of the week that matches
      while (!medicine.specificDaysOfWeek.contains(scheduled.weekday)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }

    return scheduled;
  }
}
