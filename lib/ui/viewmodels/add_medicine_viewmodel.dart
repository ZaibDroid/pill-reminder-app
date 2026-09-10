import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  int _currentStep = 0;
  final int totalSteps = 4;

  // Step 1: Basic Info
  String _name = '';
  double _dosageValue = 10.0;
  String _dosageUnit = 'mg';
  String _formFactor = 'tablet';
  String? _pillImageLocalPath;
  String _colorHex = '#00685F';
  String _intakeGuidance = 'Full glass of water';

  String get name => _name;
  set name(String val) {
    if (_name != val) {
      _name = val;
      notifyListeners();
    }
  }

  double get dosageValue => _dosageValue;
  set dosageValue(double val) {
    if (_dosageValue != val) {
      _dosageValue = val;
      notifyListeners();
    }
  }

  String get dosageUnit => _dosageUnit;
  set dosageUnit(String val) {
    if (_dosageUnit != val) {
      _dosageUnit = val;
      notifyListeners();
    }
  }

  String get formFactor => _formFactor;
  set formFactor(String val) {
    if (_formFactor != val) {
      _formFactor = val;
      final lower = val.toLowerCase();
      if (lower == 'gel' || lower == 'cream' || lower == 'ointment') {
        _intakeGuidance = 'Apply with cotton';
      } else if (lower == 'drops') {
        _intakeGuidance = 'Apply with fingertips';
      } else if (lower == 'inhaler') {
        _intakeGuidance = 'Inhale directly';
      } else {
        _intakeGuidance = 'Full glass of water';
      }
      notifyListeners();
    }
  }

  String get intakeGuidance => _intakeGuidance;
  set intakeGuidance(String val) {
    if (_intakeGuidance != val) {
      _intakeGuidance = val;
      notifyListeners();
    }
  }

  String? get pillImageLocalPath => _pillImageLocalPath;
  set pillImageLocalPath(String? val) {
    if (_pillImageLocalPath != val) {
      _pillImageLocalPath = val;
      notifyListeners();
    }
  }

  String get colorHex => _colorHex;
  set colorHex(String val) {
    if (_colorHex != val) {
      _colorHex = val;
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        _pillImageLocalPath = pickedFile.path;
        notifyListeners();
      }
    } catch (e) {
      log.e('@pickImage: Error picking image', e);
    }
  }

  void removeImage() {
    _pillImageLocalPath = null;
    notifyListeners();
  }

  // Step 2: Intake & Schedule
  MealType _mealType = MealType.afterMeal;
  FrequencyType _frequency = FrequencyType.daily;
  List<int> _specificDaysOfWeek = [1, 2, 3, 4, 5, 6, 7];
  int? _intervalHours;
  List<TimeOfDay> _reminderTimes = [
    const TimeOfDay(hour: 8, minute: 0),
  ];

  MealType get mealType => _mealType;
  set mealType(MealType val) {
    if (_mealType != val) {
      _mealType = val;
      notifyListeners();
    }
  }

  FrequencyType get frequency => _frequency;
  set frequency(FrequencyType val) {
    if (_frequency != val) {
      _frequency = val;
      notifyListeners();
    }
  }

  List<int> get specificDaysOfWeek => _specificDaysOfWeek;
  set specificDaysOfWeek(List<int> val) {
    _specificDaysOfWeek = val;
    notifyListeners();
  }

  void toggleDayOfWeek(int day) {
    final updated = List<int>.from(_specificDaysOfWeek);
    if (updated.contains(day)) {
      if (updated.length > 1) {
        updated.remove(day);
      }
    } else {
      updated.add(day);
      updated.sort();
    }
    _specificDaysOfWeek = updated;
    notifyListeners();
  }

  bool isDaySelected(int day) => _specificDaysOfWeek.contains(day);

  void selectAllDays() {
    _specificDaysOfWeek = [1, 2, 3, 4, 5, 6, 7];
    notifyListeners();
  }

  void selectWeekdaysOnly() {
    _specificDaysOfWeek = [1, 2, 3, 4, 5];
    notifyListeners();
  }

  void selectWeekendsOnly() {
    _specificDaysOfWeek = [6, 7];
    notifyListeners();
  }

  int? get intervalHours => _intervalHours;
  set intervalHours(int? val) {
    if (_intervalHours != val) {
      _intervalHours = val;
      notifyListeners();
    }
  }

  List<TimeOfDay> get reminderTimes => _reminderTimes;
  set reminderTimes(List<TimeOfDay> val) {
    _reminderTimes = val;
    notifyListeners();
  }

  // Step 3: Duration & Reminders
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isOngoing = true;
  bool _isHighPriority = false;
  String _alarmSound = 'Morning Clock Alarm';
  bool _isVibrationEnabled = true;
  String? _doctorName;
  String? _prescriptionNotes;
  int _currentStock = 30;
  int _lowStockThreshold = 5;
  bool _isRefillAlertEnabled = true;

  DateTime get startDate => _startDate;
  set startDate(DateTime val) {
    if (_startDate != val) {
      _startDate = val;
      notifyListeners();
    }
  }

  DateTime? get endDate => _endDate;
  set endDate(DateTime? val) {
    if (_endDate != val) {
      _endDate = val;
      notifyListeners();
    }
  }

  bool get isOngoing => _isOngoing;
  set isOngoing(bool val) {
    if (_isOngoing != val) {
      _isOngoing = val;
      notifyListeners();
    }
  }

  bool get isHighPriority => _isHighPriority;
  set isHighPriority(bool val) {
    if (_isHighPriority != val) {
      _isHighPriority = val;
      notifyListeners();
    }
  }

  String get alarmSound => _alarmSound;
  set alarmSound(String val) {
    if (_alarmSound != val) {
      _alarmSound = val;
      notifyListeners();
    }
  }

  bool get isVibrationEnabled => _isVibrationEnabled;
  set isVibrationEnabled(bool val) {
    if (_isVibrationEnabled != val) {
      _isVibrationEnabled = val;
      notifyListeners();
    }
  }

  String? get doctorName => _doctorName;
  set doctorName(String? val) {
    if (_doctorName != val) {
      _doctorName = val;
      notifyListeners();
    }
  }

  String? get prescriptionNotes => _prescriptionNotes;
  set prescriptionNotes(String? val) {
    if (_prescriptionNotes != val) {
      _prescriptionNotes = val;
      notifyListeners();
    }
  }

  int get currentStock => _currentStock;
  set currentStock(int val) {
    if (_currentStock != val) {
      _currentStock = val;
      notifyListeners();
    }
  }

  int get lowStockThreshold => _lowStockThreshold;
  set lowStockThreshold(int val) {
    if (_lowStockThreshold != val) {
      _lowStockThreshold = val;
      notifyListeners();
    }
  }

  bool get isRefillAlertEnabled => _isRefillAlertEnabled;
  set isRefillAlertEnabled(bool val) {
    if (_isRefillAlertEnabled != val) {
      _isRefillAlertEnabled = val;
      notifyListeners();
    }
  }

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
    _name = med.name;
    _dosageValue = med.dosageValue;
    _dosageUnit = med.dosageUnit;
    _formFactor = med.formFactor;
    _pillImageLocalPath = med.pillImageLocalPath;
    _colorHex = med.colorHex;
    _mealType = med.mealType;
    _frequency = med.frequency;
    _specificDaysOfWeek = List.from(med.specificDaysOfWeek);
    _intervalHours = med.intervalHours;
    _startDate = med.startDate;
    _endDate = med.endDate;
    _isOngoing = med.isOngoing;
    _doctorName = med.doctorName;
    _prescriptionNotes = med.prescriptionNotes;
    _intakeGuidance = med.intakeGuidance;
    _currentStock = med.currentStock;
    _lowStockThreshold = med.lowStockThreshold;
    _isRefillAlertEnabled = med.isRefillAlertEnabled;
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
    if (!_reminderTimes.any((t) => t.hour == time.hour && t.minute == time.minute)) {
      _reminderTimes.add(time);
      _reminderTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      notifyListeners();
    }
  }

  void updateReminderTime(int index, TimeOfDay newTime) {
    if (index >= 0 && index < _reminderTimes.length) {
      _reminderTimes[index] = newTime;
      _reminderTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      notifyListeners();
    }
  }

  void toggleAmPm(int index) {
    if (index >= 0 && index < _reminderTimes.length) {
      final current = _reminderTimes[index];
      final newHour = (current.hour + 12) % 24;
      _reminderTimes[index] = TimeOfDay(hour: newHour, minute: current.minute);
      _reminderTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      notifyListeners();
    }
  }

  void removeReminderTime(int index) {
    if (_reminderTimes.length > 1 && index < _reminderTimes.length) {
      _reminderTimes.removeAt(index);
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
      med.intakeGuidance = intakeGuidance.trim().isEmpty ? 'Full glass of water' : intakeGuidance.trim();
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
