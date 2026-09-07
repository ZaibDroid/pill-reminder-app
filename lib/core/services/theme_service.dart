import 'package:flutter/material.dart';
import '../../app/locator.dart';
import 'local_storage_service.dart';

/// Service managing the application's runtime [ThemeMode] and persisting preference.
class ThemeService extends ChangeNotifier {
  final LocalStorageService _localStorageService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeService({LocalStorageService? localStorageService})
      : _localStorageService = localStorageService ?? locator<LocalStorageService>() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  void _loadTheme() {
    _themeMode = _localStorageService.themeMode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _localStorageService.setThemeMode(mode);
  }

  Future<void> setThemeModeFromString(String modeStr) async {
    ThemeMode mode;
    switch (modeStr.toLowerCase()) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      case 'system':
      default:
        mode = ThemeMode.system;
        break;
    }
    await setThemeMode(mode);
  }
}
