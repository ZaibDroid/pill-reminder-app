import 'package:flutter/material.dart';
import '../../app/locator.dart';
import '../../core/enums/frequency_type.dart';
import '../../core/enums/meal_type.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/medicine.dart';
import '../../core/models/reminder_time.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/repositories/reminder_repository.dart';
import '../../core/services/alarm_service.dart';
import '../../core/services/permission_service.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class AddMedicineViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@AddMedicineViewModel');

  final MedicineRepository _medicineRepository;
  final ReminderRepository _reminderRepository;
  final AlarmService _alarmService;
  final PermissionService _permissionService;

  int _currentStep = 0;
  final int totalSteps = 4;

  // Step 1: Basic Info
  String name = '';
  double dosageValue = 10.0;
  String dosageUnit = 'mg';
  String formFactor = 'tablet';
  String? pillImageLocalPath;
  String colorHex = '#00685F';

  // Step 2: Intake & Schedule
  MealType mealType = MealType.afterMeal;
  FrequencyType frequency = FrequencyType.daily;
  List<int> specificDaysOfWeek = [1, 2, 3, 4, 5, 6, 7];
  int? intervalHours;
  List<TimeOfDay> reminderTimes = [
    const TimeOfDay(hour: 8, minute: 0),
  ];

  // Step 3: Duration & Reminders
  DateTime startDate = DateTime.now();
  DateTime? endDate;
  bool isOngoing = true;
  bool isHighPriority = false;
  String alarmSound = 'Classic Alarm';
  bool isVibrationEnabled = true;
  String? doctorName;
  String? prescriptionNotes;
  int currentStock = 30;
  int lowStockThreshold = 5;
  bool isRefillAlertEnabled = true;

  // Editing existing medicine
  final Medicine? _editingMedicine;
  bool get isEditing => _editingMedicine != null;

  String? _errorMessage;

  AddMedicineViewModel({
    MedicineRepository? medicineRepository,
    ReminderRepository? reminderRepository,
    AlarmService? alarmService,
    PermissionService? permissionService,
    Medicine? existingMedicine,
  })  : _medicineRepository = medicineRepository ?? locator<MedicineRepository>(),
        _reminderRepository = reminderRepository ?? locator<ReminderRepository>(),
        _alarmService = alarmService ?? locator<AlarmService>(),
        _permissionService = permissionService ?? locator<PermissionService>(),
        _editingMedicine = existingMedicine {
    if (existingMedicine != null) {
      _initFromExisting(existingMedicine);
    }
  }

  void _initFromExisting(Medicine med) {
    name = med.name;
    dosageValue = med.dosageValue;
    dosageUnit = med.dosageUnit;
    formFactor = med.formFactor;
    pillImageLocalPath = med.pillImageLocalPath;
    colorHex = med.colorHex;
    mealType = med.mealType;
    frequency = med.frequency;
    specificDaysOfWeek = List.from(med.specificDaysOfWeek);
    intervalHours = med.intervalHours;
    startDate = med.startDate;
    endDate = med.endDate;
    isOngoing = med.isOngoing;
    doctorName = med.doctorName;
    prescriptionNotes = med.prescriptionNotes;
    currentStock = med.currentStock;
    lowStockThreshold = med.lowStockThreshold;
    isRefillAlertEnabled = med.isRefillAlertEnabled;
  }

  int get currentStep => _currentStep;
  String? get errorMessage => _errorMessage;

  bool get isLoading => state == ViewState.busy;
  bool get hasError => state == ViewState.error;

  void setStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  bool nextStep() {
    if (validateCurrentStep()) {
      if (_currentStep < totalSteps - 1) {
        _currentStep++;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  bool validateCurrentStep() {
    _errorMessage = null;
    if (_currentStep == 0) {
      if (name.trim().isEmpty) {
        _errorMessage = 'Please enter a medicine name';
        notifyListeners();
        return false;
      }
      if (dosageValue <= 0) {
        _errorMessage = 'Please enter a valid dosage value';
        notifyListeners();
        return false;
      }
    } else if (_currentStep == 1) {
      if (reminderTimes.isEmpty) {
        _errorMessage = 'Please add at least one reminder time';
        notifyListeners();
        return false;
      }
    }
    return true;
  }

  void addReminderTime(TimeOfDay time) {
    if (!reminderTimes.any((t) => t.hour == time.hour && t.minute == time.minute)) {
      reminderTimes.add(time);
      reminderTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      notifyListeners();
    }
  }

  void removeReminderTime(int index) {
    if (reminderTimes.length > 1 && index < reminderTimes.length) {
      reminderTimes.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> saveMedication() async {
    if (!validateCurrentStep()) return false;

    setState(ViewState.busy);
    try {
      final med = _editingMedicine ?? Medicine();
      med.name = name.trim();
      med.dosageValue = dosageValue;
      med.dosageUnit = dosageUnit;
      med.formFactor = formFactor;
      med.pillImageLocalPath = pillImageLocalPath;
      med.colorHex = colorHex;
      med.mealType = mealType;
      med.frequency = frequency;
      med.specificDaysOfWeek = specificDaysOfWeek;
      med.intervalHours = intervalHours;
      med.startDate = startDate;
      med.endDate = isOngoing ? null : endDate;
      med.isOngoing = isOngoing;
      med.doctorName = doctorName?.trim();
      med.prescriptionNotes = prescriptionNotes?.trim();
      med.currentStock = currentStock;
      med.lowStockThreshold = lowStockThreshold;
      med.isRefillAlertEnabled = isRefillAlertEnabled;
      med.updatedAt = DateTime.now();

      if (isEditing) {
        await _medicineRepository.updateMedicine(med);
      } else {
        final medId = await _medicineRepository.saveMedicine(med);
        med.id = medId;
      }

      // Save new reminder times and link them to medicine
      final createdReminders = <ReminderTime>[];
      for (final time in reminderTimes) {
        final reminder = ReminderTime()
          ..hour = time.hour
          ..minute = time.minute
          ..isActive = true
          ..soundRingtone = alarmSound
          ..isVibrationEnabled = isVibrationEnabled;
        reminder.medicine.value = med;
        final rId = await _reminderRepository.saveReminderTime(reminder);
        reminder.id = rId;
        createdReminders.add(reminder);
        med.reminders.add(reminder);
      }

      // Save bidirectional relationship
      await _medicineRepository.updateMedicine(med);

      // Check and request permissions before scheduling notifications
      try {
        final hasPermissions = await _permissionService.hasAllRequiredPermissions();
        if (!hasPermissions) {
          log.i('@saveMedication: Requesting permissions prior to scheduling alarms...');
          await _permissionService.requestAllRequiredPermissions();
        }
      } catch (permError) {
        log.w('@saveMedication: Permission request encountered error, continuing schedule: $permError');
      }

      // Schedule alarms for the reminders
      await _alarmService.scheduleAllRemindersForMedicine(med, createdReminders);

      log.i('@saveMedication: Successfully saved medication ${med.name} with ${reminderTimes.length} reminders');
      setState(ViewState.idle);
      return true;
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@saveMedication: Failed to save medication', e, stackTrace);
      setState(ViewState.error);
      return false;
    }
  }
}
