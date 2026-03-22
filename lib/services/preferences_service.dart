import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String usernameKey = 'username';
  static const String darkModeKey = 'dark_mode';
  static const String notificationsKey = 'notifications_enabled';
  static const String defaultReminderTimeKey = 'default_reminder_time';
  static const String habitBuddyKey = 'habit_buddy_enabled';
  static const String weeklyReflectionKey = 'weekly_reflection_enabled';

  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, username);
  }

  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey) ?? 'Student';
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, value);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(darkModeKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationsKey, value);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationsKey) ?? true;
  }

  Future<void> setDefaultReminderTime(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(defaultReminderTimeKey, value);
  }

  Future<String> getDefaultReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(defaultReminderTimeKey) ?? '7:00 PM';
  }

  Future<void> setHabitBuddyEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(habitBuddyKey, value);
  }

  Future<bool> getHabitBuddyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(habitBuddyKey) ?? true;
  }

  Future<void> setWeeklyReflectionEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(weeklyReflectionKey, value);
  }

  Future<bool> getWeeklyReflectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(weeklyReflectionKey) ?? true;
  }
}
