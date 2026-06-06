import 'package:flutter/material.dart';

import '../services/hive_service.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService.instance;

  final HiveService _hiveService;

  ThemeMode _currentTheme = ThemeMode.system;

  ThemeMode get currentTheme => _currentTheme;

  ThemeMode get themeMode => _currentTheme;

  bool get isDarkMode => _currentTheme == ThemeMode.dark;

  Future<void> loadTheme() async {
    await _hiveService.openThemeBox();
    _currentTheme = _hiveService.getSavedTheme();
    notifyListeners();
  }

  Future<void> toggleDarkTheme() async {
    _currentTheme = ThemeMode.dark;
    await _hiveService.saveTheme(_currentTheme);
    notifyListeners();
  }

  Future<void> toggleLightTheme() async {
    _currentTheme = ThemeMode.light;
    await _hiveService.saveTheme(_currentTheme);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (isDarkMode) {
      await toggleLightTheme();
      return;
    }

    await toggleDarkTheme();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _currentTheme = themeMode;
    await _hiveService.saveTheme(_currentTheme);
    notifyListeners();
  }
}
