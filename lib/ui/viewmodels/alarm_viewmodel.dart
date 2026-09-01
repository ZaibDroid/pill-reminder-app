import '../../app/locator.dart';
import '../../core/enums/medicine_status.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/dose_log.dart';
import '../../core/models/medicine.dart';
import '../../core/models/reminder_time.dart';
import '../../core/repositories/dose_log_repository.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/services/alarm_service.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class AlarmViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@AlarmViewModel');

  final MedicineRepository _medicineRepository;
  final DoseLogRepository _doseLogRepository;
  final AlarmService _alarmService;

  Medicine? medicine;
  ReminderTime? reminderTime;
  String? _errorMessage;

  AlarmViewModel({
    MedicineRepository? medicineRepository,
    DoseLogRepository? doseLogRepository,
    AlarmService? alarmService,
  })  : _medicineRepository = medicineRepository ?? locator<MedicineRepository>(),
        _doseLogRepository = doseLogRepository ?? locator<DoseLogRepository>(),
        _alarmService = alarmService ?? locator<AlarmService>();

  String? get errorMessage => _errorMessage;

  Future<void> loadAlarmData({int? medicineId, int? reminderTimeId}) async {
    setState(ViewState.busy);
    try {
      if (medicineId != null) {
        medicine = await _medicineRepository.getMedicine(medicineId);
      }
      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@loadAlarmData: Failed to load alarm medicine', e, stackTrace);
      setState(ViewState.error);
    }
  }

  Future<void> markAsTaken() async {
    if (medicine == null) return;
    try {
      log.i('@markAsTaken: Marking alarm dose for ${medicine!.name} as taken');
      final logItem = DoseLog()
        ..scheduledDateTime = DateTime.now()
        ..actualTakenDateTime = DateTime.now()
        ..status = MedicineStatus.taken;
      logItem.medicine.value = medicine;
      if (reminderTime != null) {
        logItem.reminderTime.value = reminderTime;
      }
      await _doseLogRepository.saveDoseLog(logItem);

      if (medicine!.currentStock > 0) {
        medicine!.currentStock -= 1;
        await _medicineRepository.updateMedicine(medicine!);
      }
    } catch (e, stackTrace) {
      log.e('@markAsTaken: Error saving dose log', e, stackTrace);
      rethrow;
    }
  }

  Future<void> snooze({int durationMinutes = 10}) async {
    if (medicine == null) return;
    try {
      log.i('@snooze: Snoozing alarm for ${medicine!.name} by $durationMinutes minutes');
      final reminder = reminderTime ??
          (medicine!.reminders.isNotEmpty ? medicine!.reminders.first : ReminderTime());
      await _alarmService.snoozeAlarm(
        medicine: medicine!,
        reminder: reminder,
        durationMinutes: durationMinutes,
      );
    } catch (e, stackTrace) {
      log.e('@snooze: Error snoozing alarm', e, stackTrace);
      rethrow;
    }
  }

  Future<void> skipDose({String? reason}) async {
    if (medicine == null) return;
    try {
      log.i('@skipDose: Skipping alarm dose for ${medicine!.name}');
      final logItem = DoseLog()
        ..scheduledDateTime = DateTime.now()
        ..status = MedicineStatus.skipped
        ..skipReason = reason;
      logItem.medicine.value = medicine;
      if (reminderTime != null) {
        logItem.reminderTime.value = reminderTime;
      }
      await _doseLogRepository.saveDoseLog(logItem);
    } catch (e, stackTrace) {
      log.e('@skipDose: Error skipping dose', e, stackTrace);
      rethrow;
    }
  }
}
