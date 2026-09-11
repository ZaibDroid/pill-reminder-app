import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../app/locator.dart';
import '../../../app/routes.dart';
import '../../enums/medicine_status.dart';
import '../../models/dose_log.dart';
import '../../models/medicine.dart';
import '../../models/reminder_time.dart';
import '../../repositories/dose_log_repository.dart';
import '../../repositories/medicine_repository.dart';
import '../../utils/custom_logger.dart';
import '../alarm_service.dart';

/// Handles user actions and taps on notifications (Take, Snooze, Skip, Details, Alarm screen).
class NotificationActionHandler {
  static final _log = CustomLogger(className: '@NotificationActionHandler');

  /// Processes user interaction with notifications and action buttons.
  static Future<void> handleResponse(
    NotificationResponse response, {
    void Function(NotificationResponse)? onNotificationTap,
    Future<void> Function(Medicine medicine)? onLowStockCheck,
  }) async {
    _log.i('@handleResponse: actionId=${response.actionId}, payload=${response.payload}');
    onNotificationTap?.call(response);

    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final notificationType = data['type'] as String?;
      final medicineId = data['medicineId'] as int?;

      if (medicineId == null || !locator.isRegistered<MedicineRepository>()) {
        return;
      }

      final medRepo = locator<MedicineRepository>();
      final medicine = await medRepo.getMedicine(medicineId);
      if (medicine == null) return;

      // 1. Low-stock alert tap -> Open medicine details
      if (notificationType == 'low_stock_alert') {
        _navigateToDetails(medicine);
        return;
      }

      await medicine.reminders.load();

      // 2. Action buttons
      switch (response.actionId) {
        case 'take_action':
          await _handleTakeAction(medicine, medRepo, onLowStockCheck);
          return;

        case 'snooze_action':
          await _handleSnoozeAction(medicine);
          return;

        case 'skip_action':
          await _handleSkipAction(medicine);
          return;

        default:
          // Standard full-screen alarm tap -> Navigate to ActiveAlarmScreen
          _navigateToAlarm(medicine);
      }
    } catch (e, stackTrace) {
      _log.e('@handleResponse: Error processing notification payload', e, stackTrace);
    }
  }

  static Future<void> _handleTakeAction(
    Medicine medicine,
    MedicineRepository medRepo,
    Future<void> Function(Medicine)? onLowStockCheck,
  ) async {
    _log.i('@_handleTakeAction: Taking dose for "${medicine.name}"');
    if (locator.isRegistered<DoseLogRepository>()) {
      final doseLog = DoseLog()
        ..scheduledDateTime = DateTime.now()
        ..actualTakenDateTime = DateTime.now()
        ..status = MedicineStatus.taken;
      doseLog.medicine.value = medicine;
      await locator<DoseLogRepository>().saveDoseLog(doseLog);

      if (medicine.currentStock > 0) {
        medicine.currentStock -= 1;
        await medRepo.updateMedicine(medicine);
        await onLowStockCheck?.call(medicine);
      }
    }
  }

  static Future<void> _handleSnoozeAction(Medicine medicine) async {
    _log.i('@_handleSnoozeAction: Snoozing dose for "${medicine.name}"');
    if (locator.isRegistered<AlarmService>()) {
      final reminder = medicine.reminders.isNotEmpty
          ? medicine.reminders.first
          : ReminderTime();
      await locator<AlarmService>().snoozeAlarm(
        medicine: medicine,
        reminder: reminder,
        durationMinutes: 10,
      );
    }
  }

  static Future<void> _handleSkipAction(Medicine medicine) async {
    _log.i('@_handleSkipAction: Skipping dose for "${medicine.name}"');
    if (locator.isRegistered<DoseLogRepository>()) {
      final doseLog = DoseLog()
        ..scheduledDateTime = DateTime.now()
        ..status = MedicineStatus.skipped;
      doseLog.medicine.value = medicine;
      await locator<DoseLogRepository>().saveDoseLog(doseLog);
    }
  }

  static void _navigateToDetails(Medicine medicine) {
    _log.i('@_navigateToDetails: Opening details for "${medicine.name}"');
    AppRoutes.navigatorKey.currentState?.pushNamed(
      AppRoutes.medicineDetails,
      arguments: medicine,
    );
  }

  static void _navigateToAlarm(Medicine medicine) {
    _log.i('@_navigateToAlarm: Opening active alarm for "${medicine.name}"');
    AppRoutes.navigatorKey.currentState?.pushNamed(
      AppRoutes.alarm,
      arguments: medicine,
    );
  }
}
