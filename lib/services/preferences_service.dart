// Trajuan Smith
// This class handles persistent storage of the app settings
// using SharedPreferences.

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {

  // Keys used to store values in SharedPreferences
  static const String usernameKey = 'username';
  static const String darkModeKey = 'dark_mode';
  static const String notificationsKey = 'notifications_enabled';

  /// Saves the username to local storage
  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, username);
  }

  /// Retrieves the stored username (null if not set)
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }

  /// Enables or disables dark mode preference
  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, value);
  }

  /// Returns dark mode setting (defaults to false if not set)
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(darkModeKey) ?? false;
  }

  /// Enables or disables notifications
  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationsKey, value);
  }

  /// Returns notification setting (defaults to true if not set)
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationsKey) ?? true;
  }
}