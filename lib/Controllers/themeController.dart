import 'package:get/get.dart';

import '../Utils/packages.dart';

class ThemeController extends GetxController {
  ColorScheme _currentColorScheme = kColorScheme;
  bool _isDarkTheme = false;

  ColorScheme get currentColorScheme => _currentColorScheme;
  bool get isDarkTheme => _isDarkTheme;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    _updateColorScheme();
  }

  void _updateColorScheme() {
    _currentColorScheme = _isDarkTheme ? kDarkColorScheme : kColorScheme;
    // notifyListeners();
    update();
  }

  void toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await _saveThemePreference();
    _updateColorScheme();
  }

  Future<void> _saveThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _isDarkTheme);
  }
}
