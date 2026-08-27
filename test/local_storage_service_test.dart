import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pill_reminder_app/app/locator.dart';
import 'package:pill_reminder_app/core/services/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    service = LocalStorageService();
    await service.init();
  });

  group('LocalStorageService - Initialization & Defaults', () {
    test('init() sets isInitialized to true', () {
      expect(service.isInitialized, isTrue);
    });

    test('re-initialization is idempotent', () async {
      await service.init();
      expect(service.isInitialized, isTrue);
    });

    test('init with custom SharedPreferences instance', () async {
      SharedPreferences.setMockInitialValues({'custom_key': 'custom_val'});
      final customPrefs = await SharedPreferences.getInstance();
      final customService = LocalStorageService();
      await customService.init(preferences: customPrefs);

      expect(customService.isInitialized, isTrue);
      expect(customService.getString('custom_key'), equals('custom_val'));
    });

    test('default values match PRD specifications when storage is empty', () {
      expect(service.isFirstTimeUser, isTrue);
      expect(service.isBiometricLockEnabled, isFalse);
      expect(service.pinCodeHash, isNull);
      expect(service.isPinLockEnabled, isFalse);
      expect(service.themeMode, equals(ThemeMode.system));
      expect(service.defaultSnoozeMinutes, equals(10));
      expect(service.gracePeriodMinutes, equals(30));
      expect(service.isVibrationEnabled, isTrue);
      expect(service.alarmRingtone, isNull);
      expect(service.isNotificationsEnabled, isTrue);
    });

    test('getters return defaults safely before init() is called', () {
      final uninitializedService = LocalStorageService();
      expect(uninitializedService.isInitialized, isFalse);
      expect(uninitializedService.isFirstTimeUser, isTrue);
      expect(uninitializedService.isBiometricLockEnabled, isFalse);
      expect(uninitializedService.pinCodeHash, isNull);
      expect(uninitializedService.isPinLockEnabled, isFalse);
      expect(uninitializedService.themeMode, equals(ThemeMode.system));
      expect(uninitializedService.defaultSnoozeMinutes, equals(10));
      expect(uninitializedService.gracePeriodMinutes, equals(30));
      expect(uninitializedService.isVibrationEnabled, isTrue);
      expect(uninitializedService.alarmRingtone, isNull);
      expect(uninitializedService.isNotificationsEnabled, isTrue);
    });
  });

  group('LocalStorageService - PRD Properties & Preferences', () {
    test('isFirstTimeUser getter and setter', () async {
      expect(service.isFirstTimeUser, isTrue);

      final setResult = await service.setFirstTimeUser(false);
      expect(setResult, isTrue);
      expect(service.isFirstTimeUser, isFalse);

      await service.setFirstTimeUser(true);
      expect(service.isFirstTimeUser, isTrue);
    });

    test('isBiometricLockEnabled getter and setter', () async {
      expect(service.isBiometricLockEnabled, isFalse);

      final setResult = await service.setBiometricLockEnabled(true);
      expect(setResult, isTrue);
      expect(service.isBiometricLockEnabled, isTrue);

      await service.setBiometricLockEnabled(false);
      expect(service.isBiometricLockEnabled, isFalse);
    });

    test('pinCodeHash getter, setter, clearPinCodeHash and isPinLockEnabled', () async {
      expect(service.pinCodeHash, isNull);
      expect(service.isPinLockEnabled, isFalse);

      const sampleHash = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
      final setResult = await service.setPinCodeHash(sampleHash);
      expect(setResult, isTrue);
      expect(service.pinCodeHash, equals(sampleHash));
      expect(service.isPinLockEnabled, isTrue);

      // Clearing via clearPinCodeHash()
      final clearResult = await service.clearPinCodeHash();
      expect(clearResult, isTrue);
      expect(service.pinCodeHash, isNull);
      expect(service.isPinLockEnabled, isFalse);

      // Setting with null
      await service.setPinCodeHash(sampleHash);
      expect(service.pinCodeHash, equals(sampleHash));
      await service.setPinCodeHash(null);
      expect(service.pinCodeHash, isNull);
      expect(service.isPinLockEnabled, isFalse);

      // Setting with empty string
      await service.setPinCodeHash(sampleHash);
      await service.setPinCodeHash('');
      expect(service.pinCodeHash, isNull);
      expect(service.isPinLockEnabled, isFalse);
    });

    test('themeMode getter and setter for light, dark, and system', () async {
      expect(service.themeMode, equals(ThemeMode.system));

      await service.setThemeMode(ThemeMode.light);
      expect(service.themeMode, equals(ThemeMode.light));

      await service.setThemeMode(ThemeMode.dark);
      expect(service.themeMode, equals(ThemeMode.dark));

      await service.setThemeMode(ThemeMode.system);
      expect(service.themeMode, equals(ThemeMode.system));
    });

    test('defaultSnoozeMinutes getter and setter', () async {
      expect(service.defaultSnoozeMinutes, equals(10));

      final setResult = await service.setDefaultSnoozeMinutes(15);
      expect(setResult, isTrue);
      expect(service.defaultSnoozeMinutes, equals(15));

      await service.setDefaultSnoozeMinutes(5);
      expect(service.defaultSnoozeMinutes, equals(5));
    });

    test('gracePeriodMinutes getter and setter', () async {
      expect(service.gracePeriodMinutes, equals(30));

      final setResult = await service.setGracePeriodMinutes(60);
      expect(setResult, isTrue);
      expect(service.gracePeriodMinutes, equals(60));

      await service.setGracePeriodMinutes(15);
      expect(service.gracePeriodMinutes, equals(15));
    });

    test('isVibrationEnabled getter and setter', () async {
      expect(service.isVibrationEnabled, isTrue);

      final setResult = await service.setVibrationEnabled(false);
      expect(setResult, isTrue);
      expect(service.isVibrationEnabled, isFalse);

      await service.setVibrationEnabled(true);
      expect(service.isVibrationEnabled, isTrue);
    });

    test('alarmRingtone getter, setter and removal', () async {
      expect(service.alarmRingtone, isNull);

      const tone = 'assets/audio/gentle_chime.mp3';
      final setResult = await service.setAlarmRingtone(tone);
      expect(setResult, isTrue);
      expect(service.alarmRingtone, equals(tone));

      // Clear ringtone
      await service.setAlarmRingtone(null);
      expect(service.alarmRingtone, isNull);

      // Clear ringtone with empty string
      await service.setAlarmRingtone(tone);
      await service.setAlarmRingtone('');
      expect(service.alarmRingtone, isNull);
    });

    test('isNotificationsEnabled getter and setter', () async {
      expect(service.isNotificationsEnabled, isTrue);

      final setResult = await service.setNotificationsEnabled(false);
      expect(setResult, isTrue);
      expect(service.isNotificationsEnabled, isFalse);

      await service.setNotificationsEnabled(true);
      expect(service.isNotificationsEnabled, isTrue);
    });
  });

  group('LocalStorageService - Generic Type Helpers & Utilities', () {
    test('string getter and setter', () async {
      expect(service.getString('key_str'), isNull);
      expect(service.getString('key_str', defaultValue: 'default'), equals('default'));

      await service.setString('key_str', 'test_value');
      expect(service.getString('key_str'), equals('test_value'));
    });

    test('bool getter and setter', () async {
      expect(service.getBool('key_bool'), isFalse);
      expect(service.getBool('key_bool', defaultValue: true), isTrue);

      await service.setBool('key_bool', true);
      expect(service.getBool('key_bool'), isTrue);
    });

    test('int getter and setter', () async {
      expect(service.getInt('key_int'), equals(0));
      expect(service.getInt('key_int', defaultValue: 42), equals(42));

      await service.setInt('key_int', 100);
      expect(service.getInt('key_int'), equals(100));
    });

    test('double getter and setter', () async {
      expect(service.getDouble('key_double'), isNull);
      expect(service.getDouble('key_double', defaultValue: 3.14), equals(3.14));

      await service.setDouble('key_double', 99.9);
      expect(service.getDouble('key_double'), equals(99.9));
    });

    test('string list getter and setter', () async {
      expect(service.getStringList('key_list'), isNull);

      final list = ['item1', 'item2', 'item3'];
      await service.setStringList('key_list', list);
      expect(service.getStringList('key_list'), equals(list));
    });

    test('containsKey returns true only when key exists', () async {
      expect(service.containsKey('some_key'), isFalse);

      await service.setString('some_key', 'val');
      expect(service.containsKey('some_key'), isTrue);
    });

    test('remove deletes the specified key', () async {
      await service.setString('to_remove', 'val');
      expect(service.containsKey('to_remove'), isTrue);

      final removeResult = await service.remove('to_remove');
      expect(removeResult, isTrue);
      expect(service.containsKey('to_remove'), isFalse);
    });

    test('clearAll removes all saved preferences', () async {
      await service.setFirstTimeUser(false);
      await service.setBiometricLockEnabled(true);
      await service.setString('extra_key', 'extra_value');

      final clearResult = await service.clearAll();
      expect(clearResult, isTrue);

      expect(service.containsKey('extra_key'), isFalse);
      expect(service.isFirstTimeUser, isTrue); // reset to default
      expect(service.isBiometricLockEnabled, isFalse); // reset to default
    });
  });

  group('LocalStorageService - GetIt Locator Integration', () {
    setUp(() {
      if (!locator.isRegistered<LocalStorageService>()) {
        setupLocator();
      }
    });

    test('locator resolves LocalStorageService singleton', () {
      final resolved = locator<LocalStorageService>();
      expect(resolved, isNotNull);
      expect(resolved, isA<LocalStorageService>());
    });
  });
}
