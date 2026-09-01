import 'dart:convert';
import '../../app/locator.dart';
import '../../core/enums/view_state.dart';
import '../../core/models/user_settings.dart';
import '../../core/repositories/medicine_repository.dart';
import '../../core/repositories/user_settings_repository.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/utils/custom_logger.dart';
import '../../core/view_model/base_view_model.dart';

class SettingsViewModel extends BaseViewModel {
  final log = CustomLogger(className: '@SettingsViewModel');

  final UserSettingsRepository _userSettingsRepository;
  final LocalStorageService _localStorageService;
  final MedicineRepository _medicineRepository;

  UserSettings? _settings;
  String _userName = 'Eleanor Vance';
  String _patientId = '#MA-9482';
  String? _errorMessage;

  SettingsViewModel({
    UserSettingsRepository? userSettingsRepository,
    LocalStorageService? localStorageService,
    MedicineRepository? medicineRepository,
  })  : _userSettingsRepository = userSettingsRepository ?? locator<UserSettingsRepository>(),
        _localStorageService = localStorageService ?? locator<LocalStorageService>(),
        _medicineRepository = medicineRepository ?? locator<MedicineRepository>();

  UserSettings? get settings => _settings;
  String get userName => _userName;
  String get patientId => _patientId;
  String? get errorMessage => _errorMessage;

  bool get isLoading => state == ViewState.busy;
  bool get hasError => state == ViewState.error;

  bool get isHighPriorityAlarmEnabled => _settings?.vibrationEnabled ?? true;
  String get alarmSound => _settings?.soundName ?? 'Clinical Chime';
  String get themeMode => _settings?.themeMode ?? 'system';
  bool get isPinLockEnabled => _settings?.pinHash != null && _settings!.pinHash!.isNotEmpty;
  bool get isBiometricEnabled => _settings?.isBiometricEnabled ?? false;

  Future<void> loadSettings() async {
    setState(ViewState.busy);
    try {
      _settings = await _userSettingsRepository.getOrCreateSettings();
      _userName = _localStorageService.getString('user_name') ?? 'Eleanor Vance';
      _patientId = _localStorageService.getString('patient_id') ?? '#MA-9482';
      log.i('@loadSettings: Settings loaded successfully');
      setState(ViewState.idle);
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      log.e('@loadSettings: Failed to load settings', e, stackTrace);
      setState(ViewState.error);
    }
  }

  Future<void> setHighPriorityAlarm(bool value) async {
    if (_settings == null) return;
    _settings!.vibrationEnabled = value;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
  }

  Future<void> setAlarmSound(String sound) async {
    if (_settings == null) return;
    _settings!.soundName = sound;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
  }

  Future<void> setThemeMode(String mode) async {
    if (_settings == null) return;
    _settings!.themeMode = mode;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
  }

  Future<void> setPin(String? pin) async {
    if (_settings == null) return;
    _settings!.pinHash = pin;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
  }

  Future<void> setBiometric(bool value) async {
    if (_settings == null) return;
    _settings!.isBiometricEnabled = value;
    notifyListeners();
    await _userSettingsRepository.saveUserSettings(_settings!);
  }

  Future<String> exportDataJson() async {
    try {
      final medicines = await _medicineRepository.getAllMedicines();
      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'user': {'name': _userName, 'patientId': _patientId},
        'medicines': medicines.map((m) => {
          'name': m.name,
          'dosage': '${m.dosageValue} ${m.dosageUnit}',
          'frequency': m.frequency.name,
          'stock': m.currentStock,
        }).toList(),
      };
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      log.e('@exportDataJson: Failed to export data', e);
      rethrow;
    }
  }
}
