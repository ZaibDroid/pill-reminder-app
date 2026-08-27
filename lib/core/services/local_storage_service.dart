import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/custom_logger.dart';

/// Service responsible for managing local, offline non-database app preferences.
///
/// Uses [SharedPreferences] under the hood to store user configuration,
/// theme mode, onboarding state, alarm settings, and security flags.
class LocalStorageService {
  final log = CustomLogger(className: '@LocalStorageService');

  // Storage Keys
  static const String keyIsFirstTimeUser = 'is_first_time_user';
  static const String keyIsBiometricLockEnabled = 'is_biometric_lock_enabled';
  static const String keyPinCodeHash = 'pin_code_hash';
  static const String keyThemeMode = 'theme_mode';
  static const String keyDefaultSnoozeMinutes = 'default_snooze_minutes';
  static const String keyGracePeriodMinutes = 'grace_period_minutes';
  static const String keyIsVibrationEnabled = 'is_vibration_enabled';
  static const String keyAlarmRingtone = 'alarm_ringtone';
  static const String keyIsNotificationsEnabled = 'is_notifications_enabled';

  SharedPreferences? _preferences;

  /// Returns true if [SharedPreferences] has been initialized.
  bool get isInitialized => _preferences != null;

  /// Initializes the [LocalStorageService].
  ///
  /// Optionally accepts an injected [preferences] instance for unit testing.
  Future<void> init({SharedPreferences? preferences}) async {
    try {
      if (preferences != null) {
        _preferences = preferences;
        log.i('@init: Initialized with custom SharedPreferences instance');
        return;
      }

      if (_preferences == null) {
        log.i('@init: Loading SharedPreferences instance...');
        _preferences = await SharedPreferences.getInstance();
        log.i('@init: SharedPreferences initialized successfully');
      } else {
        log.d('@init: SharedPreferences already initialized');
      }
    } catch (e, stackTrace) {
      log.e('@init: Failed to initialize SharedPreferences', e, stackTrace);
      rethrow;
    }
  }

  /// Internal helper to ensure preferences instance is ready before write operations.
  Future<SharedPreferences> _ensurePrefs() async {
    if (_preferences == null) {
      log.d('@_ensurePrefs: Preferences not initialized, fetching instance...');
      _preferences = await SharedPreferences.getInstance();
    }
    return _preferences!;
  }

  // ===========================================================================
  // PRD Stored App Preferences
  // ===========================================================================

  /// Whether the app is opened for the first time by the user.
  /// Defaults to `true`.
  bool get isFirstTimeUser {
    final value = _preferences?.getBool(keyIsFirstTimeUser) ?? true;
    log.d('@isFirstTimeUser: Retrieved isFirstTimeUser = $value');
    return value;
  }

  /// Sets the first-time user flag.
  Future<bool> setFirstTimeUser(bool val) async {
    try {
      log.i('@setFirstTimeUser: Setting isFirstTimeUser to $val');
      final prefs = await _ensurePrefs();
      return await prefs.setBool(keyIsFirstTimeUser, val);
    } catch (e, stackTrace) {
      log.e('@setFirstTimeUser: Error setting isFirstTimeUser', e, stackTrace);
      return false;
    }
  }

  /// Whether biometric lock (Face ID / Fingerprint) is enabled.
  /// Defaults to `false`.
  bool get isBiometricLockEnabled {
    final value = _preferences?.getBool(keyIsBiometricLockEnabled) ?? false;
    log.d('@isBiometricLockEnabled: Retrieved isBiometricLockEnabled = $value');
    return value;
  }

  /// Sets whether biometric lock is enabled.
  Future<bool> setBiometricLockEnabled(bool val) async {
    try {
      log.i('@setBiometricLockEnabled: Setting isBiometricLockEnabled to $val');
      final prefs = await _ensurePrefs();
      return await prefs.setBool(keyIsBiometricLockEnabled, val);
    } catch (e, stackTrace) {
      log.e('@setBiometricLockEnabled: Error setting isBiometricLockEnabled', e, stackTrace);
      return false;
    }
  }

  /// The SHA-256 hashed 4-digit PIN code for app lock, or `null` if not configured.
  String? get pinCodeHash {
    final value = _preferences?.getString(keyPinCodeHash);
    log.d('@pinCodeHash: Retrieved pinCodeHash = ${value != null ? '[PROTECTED]' : 'null'}');
    return value;
  }

  /// Sets or clears the PIN code hash. Passing `null` or empty string removes the PIN lock.
  Future<bool> setPinCodeHash(String? hash) async {
    try {
      final prefs = await _ensurePrefs();
      if (hash == null || hash.isEmpty) {
        log.i('@setPinCodeHash: Clearing pinCodeHash');
        return await prefs.remove(keyPinCodeHash);
      }
      log.i('@setPinCodeHash: Setting new pinCodeHash');
      return await prefs.setString(keyPinCodeHash, hash);
    } catch (e, stackTrace) {
      log.e('@setPinCodeHash: Error setting pinCodeHash', e, stackTrace);
      return false;
    }
  }

  /// Clears the configured PIN code hash.
  Future<bool> clearPinCodeHash() async {
    return await setPinCodeHash(null);
  }

  /// Whether PIN lock is currently enabled.
  bool get isPinLockEnabled => pinCodeHash != null && pinCodeHash!.isNotEmpty;

  /// The active [ThemeMode] preference.
  /// Defaults to [ThemeMode.system].
  ThemeMode get themeMode {
    final raw = _preferences?.getString(keyThemeMode);
    log.d('@themeMode: Retrieved raw themeMode = $raw');
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Persists the selected [ThemeMode].
  Future<bool> setThemeMode(ThemeMode mode) async {
    try {
      log.i('@setThemeMode: Setting themeMode to $mode');
      final prefs = await _ensurePrefs();
      String stringVal;
      switch (mode) {
        case ThemeMode.light:
          stringVal = 'light';
          break;
        case ThemeMode.dark:
          stringVal = 'dark';
          break;
        case ThemeMode.system:
          stringVal = 'system';
          break;
      }
      return await prefs.setString(keyThemeMode, stringVal);
    } catch (e, stackTrace) {
      log.e('@setThemeMode: Error setting themeMode', e, stackTrace);
      return false;
    }
  }

  /// The default snooze duration in minutes.
  /// Defaults to `10` minutes per PRD specifications.
  int get defaultSnoozeMinutes {
    final value = _preferences?.getInt(keyDefaultSnoozeMinutes) ?? 10;
    log.d('@defaultSnoozeMinutes: Retrieved defaultSnoozeMinutes = $value');
    return value;
  }

  /// Sets the default snooze duration in minutes.
  Future<bool> setDefaultSnoozeMinutes(int mins) async {
    try {
      log.i('@setDefaultSnoozeMinutes: Setting defaultSnoozeMinutes to $mins');
      final prefs = await _ensurePrefs();
      return await prefs.setInt(keyDefaultSnoozeMinutes, mins);
    } catch (e, stackTrace) {
      log.e('@setDefaultSnoozeMinutes: Error setting defaultSnoozeMinutes', e, stackTrace);
      return false;
    }
  }

  /// The grace period before an unattended alarm transitions to `Missed`.
  /// Defaults to `30` minutes per PRD specifications.
  int get gracePeriodMinutes {
    final value = _preferences?.getInt(keyGracePeriodMinutes) ?? 30;
    log.d('@gracePeriodMinutes: Retrieved gracePeriodMinutes = $value');
    return value;
  }

  /// Sets the missed dose grace period in minutes.
  Future<bool> setGracePeriodMinutes(int mins) async {
    try {
      log.i('@setGracePeriodMinutes: Setting gracePeriodMinutes to $mins');
      final prefs = await _ensurePrefs();
      return await prefs.setInt(keyGracePeriodMinutes, mins);
    } catch (e, stackTrace) {
      log.e('@setGracePeriodMinutes: Error setting gracePeriodMinutes', e, stackTrace);
      return false;
    }
  }

  /// Whether vibration is enabled for alarms and reminders.
  /// Defaults to `true`.
  bool get isVibrationEnabled {
    final value = _preferences?.getBool(keyIsVibrationEnabled) ?? true;
    log.d('@isVibrationEnabled: Retrieved isVibrationEnabled = $value');
    return value;
  }

  /// Sets whether vibration is enabled.
  Future<bool> setVibrationEnabled(bool val) async {
    try {
      log.i('@setVibrationEnabled: Setting isVibrationEnabled to $val');
      final prefs = await _ensurePrefs();
      return await prefs.setBool(keyIsVibrationEnabled, val);
    } catch (e, stackTrace) {
      log.e('@setVibrationEnabled: Error setting isVibrationEnabled', e, stackTrace);
      return false;
    }
  }

  /// Custom alarm ringtone identifier or asset path, or `null` for system default.
  String? get alarmRingtone {
    final value = _preferences?.getString(keyAlarmRingtone);
    log.d('@alarmRingtone: Retrieved alarmRingtone = $value');
    return value;
  }

  /// Sets or resets the custom alarm ringtone.
  Future<bool> setAlarmRingtone(String? ringtone) async {
    try {
      final prefs = await _ensurePrefs();
      if (ringtone == null || ringtone.isEmpty) {
        log.i('@setAlarmRingtone: Removing custom alarm ringtone');
        return await prefs.remove(keyAlarmRingtone);
      }
      log.i('@setAlarmRingtone: Setting custom alarm ringtone to $ringtone');
      return await prefs.setString(keyAlarmRingtone, ringtone);
    } catch (e, stackTrace) {
      log.e('@setAlarmRingtone: Error setting alarm ringtone', e, stackTrace);
      return false;
    }
  }

  /// Whether notification reminders are globally enabled.
  /// Defaults to `true`.
  bool get isNotificationsEnabled {
    final value = _preferences?.getBool(keyIsNotificationsEnabled) ?? true;
    log.d('@isNotificationsEnabled: Retrieved isNotificationsEnabled = $value');
    return value;
  }

  /// Sets whether notification reminders are enabled.
  Future<bool> setNotificationsEnabled(bool val) async {
    try {
      log.i('@setNotificationsEnabled: Setting isNotificationsEnabled to $val');
      final prefs = await _ensurePrefs();
      return await prefs.setBool(keyIsNotificationsEnabled, val);
    } catch (e, stackTrace) {
      log.e('@setNotificationsEnabled: Error setting isNotificationsEnabled', e, stackTrace);
      return false;
    }
  }

  // ===========================================================================
  // Generic Preference Helpers
  // ===========================================================================

  /// Reads a string value for the given [key], or returns [defaultValue].
  String? getString(String key, {String? defaultValue}) {
    return _preferences?.getString(key) ?? defaultValue;
  }

  /// Persists a string value for the given [key].
  Future<bool> setString(String key, String value) async {
    try {
      final prefs = await _ensurePrefs();
      return await prefs.setString(key, value);
    } catch (e, stackTrace) {
      log.e('@setString: Error setting string for key "$key"', e, stackTrace);
      return false;
    }
  }

  /// Reads a boolean value for the given [key], or returns [defaultValue].
  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  /// Persists a boolean value for the given [key].
  Future<bool> setBool(String key, bool value) async {
    try {
      final prefs = await _ensurePrefs();
      return await prefs.setBool(key, value);
    } catch (e, stackTrace) {
      log.e('@setBool: Error setting bool for key "$key"', e, stackTrace);
      return false;
    }
  }

  /// Reads an integer value for the given [key], or returns [defaultValue].
  int getInt(String key, {int defaultValue = 0}) {
    return _preferences?.getInt(key) ?? defaultValue;
  }

  /// Persists an integer value for the given [key].
  Future<bool> setInt(String key, int value) async {
    try {
      final prefs = await _ensurePrefs();
      return await prefs.setInt(key, value);
    } catch (e, stackTrace) {
      log.e('@setInt: Error setting int for key "$key"', e, stackTrace);
      return false;
    }
  }

  /// Reads a double value for the given [key], or returns [defaultValue].
  double? getDouble(String key, {double? defaultValue}) {
    return _preferences?.getDouble(key) ?? defaultValue;
  }

  /// Persists a double value for the given [key].
  Future<bool> setDouble(String key, double value) async {
    try {
      final prefs = await _ensurePrefs();
      return await prefs.setDouble(key, value);
    } catch (e, stackTrace) {
      log.e('@setDouble: Error setting double for key "$key"', e, stackTrace);
      return false;
    }
  }

  /// Reads a list of strings for the given [key], or returns `null`.
  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }

  /// Persists a list of strings for the given [key].
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final prefs = await _ensurePrefs();
      return await prefs.setStringList(key, value);
    } catch (e, stackTrace) {
      log.e('@setStringList: Error setting string list for key "$key"', e, stackTrace);
      return false;
    }
  }

  /// Returns true if [key] is present in preferences.
  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  /// Removes a preference entry by [key].
  Future<bool> remove(String key) async {
    try {
      log.d('@remove: Removing key "$key"');
      final prefs = await _ensurePrefs();
      return await prefs.remove(key);
    } catch (e, stackTrace) {
      log.e('@remove: Error removing key "$key"', e, stackTrace);
      return false;
    }
  }

  /// Clears all preferences from local storage.
  Future<bool> clearAll() async {
    try {
      log.w('@clearAll: Clearing all SharedPreferences data');
      final prefs = await _ensurePrefs();
      return await prefs.clear();
    } catch (e, stackTrace) {
      log.e('@clearAll: Error clearing all preferences', e, stackTrace);
      return false;
    }
  }
}
