import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pill_reminder_app/core/services/local_storage_service.dart';
import 'package:pill_reminder_app/core/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService localStorageService;
  late ThemeService themeService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    localStorageService = LocalStorageService();
    await localStorageService.init(preferences: prefs);
    themeService = ThemeService(localStorageService: localStorageService);
  });

  group('ThemeService Tests', () {
    test('Default theme is system', () {
      expect(themeService.themeMode, equals(ThemeMode.system));
      expect(themeService.themeModeString, equals('system'));
    });

    test('Switches to dark mode and notifies listeners', () async {
      bool notified = false;
      themeService.addListener(() => notified = true);

      await themeService.setThemeMode(ThemeMode.dark);

      expect(themeService.themeMode, equals(ThemeMode.dark));
      expect(themeService.themeModeString, equals('dark'));
      expect(notified, isTrue);
      expect(localStorageService.themeMode, equals(ThemeMode.dark));
    });

    test('Switches to light mode from string', () async {
      await themeService.setThemeModeFromString('light');

      expect(themeService.themeMode, equals(ThemeMode.light));
      expect(themeService.themeModeString, equals('light'));
      expect(localStorageService.themeMode, equals(ThemeMode.light));
    });
  });
}
