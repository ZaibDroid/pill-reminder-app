import 'package:url_launcher/url_launcher.dart';
import '../../app/locator.dart';
import '../../core/enums/medicine_status.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/dose_log.dart';
import '../../core/models/emergency_contact.dart';
import '../../core/models/medicine.dart';
import '../../core/models/reminder_time.dart';
import '../../core/repositories/dose_log_repository.dart';
import '../../core/repositories/emergency_contact_repository.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/repositories/user_settings_repository.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/audio_alarm_service.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class AlarmViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@AlarmViewModel');

  final MedicineRepository _medicineRepository;
  final DoseLogRepository _doseLogRepository;
  final AlarmService _alarmService;
  final AudioAlarmService _audioAlarmService;
  final EmergencyContactRepository _emergencyContactRepository;

  Medicine? medicine;
  ReminderTime? reminderTime;
  EmergencyContact? primaryCaregiverContact;
  String? _errorMessage;
  bool _hasStartedAlarm = false;

  AlarmViewModel({
    MedicineRepository? medicineRepository,
    DoseLogRepository? doseLogRepository,
    AlarmService? alarmService,
    AudioAlarmService? audioAlarmService,
    EmergencyContactRepository? emergencyContactRepository,
  })  : _medicineRepository = medicineRepository ?? locator<MedicineRepository>(),
        _doseLogRepository = doseLogRepository ?? locator<DoseLogRepository>(),
        _alarmService = alarmService ?? locator<AlarmService>(),
        _audioAlarmService = audioAlarmService ?? locator<AudioAlarmService>(),
        _emergencyContactRepository = emergencyContactRepository ?? locator<EmergencyContactRepository>();

  String? get errorMessage => _errorMessage;
  bool get hasCaregiver => primaryCaregiverContact != null;

  /// Initializes the active alarm session, loads medicine/reminders and starts audio/vibration.
  Future<void> initializeAlarm({Medicine? initialMedicine, int? medicineId, int? reminderTimeId}) async {
    if (initialMedicine != null) {
      medicine = initialMedicine;
    }

    setState(ViewState.busy);
    try {
      if (medicine == null && medicineId != null) {
        medicine = await _medicineRepository.getMedicine(medicineId);
      }

      if (medicine != null) {
        try {
          await medicine!.reminders.load();
        } catch (_) {}
        if (reminderTimeId != null && medicine!.reminders.isNotEmpty) {
          try {
            reminderTime = medicine!.reminders.firstWhere((r) => r.id == reminderTimeId);
          } catch (_) {
            reminderTime = medicine!.reminders.first;
          }
        } else if (medicine!.reminders.isNotEmpty) {
          reminderTime = medicine!.reminders.first;
        }
      }

      // Load primary emergency caregiver contact
      final contacts = await _emergencyContactRepository.getAllEmergencyContacts();
      try {
        primaryCaregiverContact = contacts.firstWhere((c) => c.isPrimary);
      } catch (_) {
        primaryCaregiverContact = contacts.isNotEmpty ? contacts.first : null;
      }

      // Start continuous audio & vibration ring if not started yet
      if (!_hasStartedAlarm) {
        _hasStartedAlarm = true;
        String? soundName;
        if (locator.isRegistered<UserSettingsRepository>()) {
          try {
            final settings = await locator<UserSettingsRepository>().getOrCreateSettings();
            soundName = settings.soundName;
          } catch (_) {}
        }
        await _audioAlarmService.startAlarm(
          soundName: soundName ?? 'Clinical Chime',
          enableVibration: reminderTime?.isVibrationEnabled ?? true,
        );
      }

      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@initializeAlarm: Failed to load alarm medicine or contacts', e, stackTrace);
      setState(ViewState.error);
    }
  }

  Future<void> markAsTaken() async {
    await _audioAlarmService.stopAlarm();
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
      notifyListeners();
    } catch (e, stackTrace) {
      log.e('@markAsTaken: Error saving dose log', e, stackTrace);
      rethrow;
    }
  }

  Future<void> snooze({int durationMinutes = 10}) async {
    await _audioAlarmService.stopAlarm();
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
      notifyListeners();
    } catch (e, stackTrace) {
      log.e('@snooze: Error snoozing alarm', e, stackTrace);
      rethrow;
    }
  }

  Future<void> skipDose({String? reason}) async {
    await _audioAlarmService.stopAlarm();
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
      notifyListeners();
    } catch (e, stackTrace) {
      log.e('@skipDose: Error skipping dose', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> callCaregiver() async {
    if (primaryCaregiverContact == null || primaryCaregiverContact!.phoneNumber.isEmpty) {
      return false;
    }
    final cleanNumber = primaryCaregiverContact!.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      log.i('@callCaregiver: Launching dialer for caregiver $cleanNumber');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e, stackTrace) {
      log.e('@callCaregiver: Error launching dialer for caregiver', e, stackTrace);
      return false;
    }
  }

  @override
  void dispose() {
    _audioAlarmService.stopAlarm();
    super.dispose();
  }
}
