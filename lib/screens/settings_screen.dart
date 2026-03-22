import 'package:flutter/material.dart';

import '../data/habit_repository.dart';
import '../services/preferences_service.dart';
import '../widgets/info_card.dart';

class SettingsScreen extends StatefulWidget {
  final bool initialDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.initialDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _preferences = PreferencesService();
  final _repository = HabitRepository();
  final _usernameController = TextEditingController();
  final _reminderTimes = [
    '6:00 AM',
    '7:00 AM',
    '8:00 AM',
    '12:00 PM',
    '5:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
  ];

  bool _darkMode = true;
  bool _notificationsEnabled = true;
  bool _habitBuddyEnabled = true;
  bool _weeklyReflectionEnabled = true;
  String _defaultReminderTime = '7:00 PM';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.initialDarkMode;
    _load();
  }

  Future<void> _load() async {
    _usernameController.text = await _preferences.getUsername();
    _darkMode = await _preferences.getDarkMode();
    _notificationsEnabled = await _preferences.getNotificationsEnabled();
    _habitBuddyEnabled = await _preferences.getHabitBuddyEnabled();
    _weeklyReflectionEnabled = await _preferences.getWeeklyReflectionEnabled();
    _defaultReminderTime = await _preferences.getDefaultReminderTime();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    await _preferences.setUsername(_usernameController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Username saved.')));
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all habit data?'),
        content: const Text(
          'Are you sure you want to delete all habit data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.resetAllHabitData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All habit data has been reset.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoCard(
            title: 'Profile',
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveUsername,
                    child: const Text('Save Username'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InfoCard(
            title: 'Theme',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark Mode'),
              value: _darkMode,
              onChanged: (value) async {
                setState(() => _darkMode = value);
                await _preferences.setDarkMode(value);
                widget.onThemeChanged(value);
              },
            ),
          ),
          const SizedBox(height: 14),
          InfoCard(
            title: 'Notifications',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Habit Reminder Notifications'),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() => _notificationsEnabled = value);
                    await _preferences.setNotificationsEnabled(value);
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _defaultReminderTime,
                  decoration: const InputDecoration(
                    labelText: 'Default Reminder Time',
                  ),
                  items: _reminderTimes
                      .map(
                        (time) =>
                            DropdownMenuItem(value: time, child: Text(time)),
                      )
                      .toList(),
                  onChanged: _notificationsEnabled
                      ? (value) async {
                          if (value == null) return;
                          setState(() => _defaultReminderTime = value);
                          await _preferences.setDefaultReminderTime(value);
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InfoCard(
            title: 'Habit Preferences',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Habit Buddy Suggestions'),
                  value: _habitBuddyEnabled,
                  onChanged: (value) async {
                    setState(() => _habitBuddyEnabled = value);
                    await _preferences.setHabitBuddyEnabled(value);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Weekly Reflection Messages'),
                  value: _weeklyReflectionEnabled,
                  onChanged: (value) async {
                    setState(() => _weeklyReflectionEnabled = value);
                    await _preferences.setWeeklyReflectionEnabled(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InfoCard(
            title: 'Data Management',
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmReset,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Reset All Habit Data'),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const InfoCard(
            title: 'App Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Habit Mastery League'),
                SizedBox(height: 4),
                Text('Version 1.0.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
