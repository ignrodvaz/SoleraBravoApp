import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  
  // Preferencias
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _notificationSound = true;
  bool _analyticsEnabled = true;
  String _language = 'es';

  // Getters
  bool get darkMode => _darkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notificationSound => _notificationSound;
  bool get analyticsEnabled => _analyticsEnabled;
  String get language => _language;

  SettingsProvider() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPreferences();
  }

  void _loadPreferences() {
    _darkMode = _prefs.getBool('darkMode') ?? false;
    _notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    _notificationSound = _prefs.getBool('notificationSound') ?? true;
    _analyticsEnabled = _prefs.getBool('analyticsEnabled') ?? true;
    _language = _prefs.getString('language') ?? 'es';
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    _prefs.setBool('darkMode', _darkMode);
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _prefs.setBool('notificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  void toggleNotificationSound() {
    _notificationSound = !_notificationSound;
    _prefs.setBool('notificationSound', _notificationSound);
    notifyListeners();
  }

  void toggleAnalytics() {
    _analyticsEnabled = !_analyticsEnabled;
    _prefs.setBool('analyticsEnabled', _analyticsEnabled);
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    _prefs.setString('language', language);
    notifyListeners();
  }

  void clearCache() {
    // Aquí puedes implementar la lógica para limpiar caché
    // Por ejemplo, si usas un servicio de caché o almacenamiento local
    _prefs.remove('cacheData');
    notifyListeners();
  }

  void resetToDefaults() {
    _darkMode = false;
    _notificationsEnabled = true;
    _notificationSound = true;
    _analyticsEnabled = true;
    _language = 'es';
    
    _prefs.setBool('darkMode', _darkMode);
    _prefs.setBool('notificationsEnabled', _notificationsEnabled);
    _prefs.setBool('notificationSound', _notificationSound);
    _prefs.setBool('analyticsEnabled', _analyticsEnabled);
    _prefs.setString('language', _language);
    
    notifyListeners();
  }
}
