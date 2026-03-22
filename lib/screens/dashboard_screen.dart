import 'package:flutter/material.dart';

import '../data/habit_repository.dart';
import '../models/habits.dart';
import '../services/preferences_service.dart';
import '../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repository = HabitRepository();
  final _preferences = PreferencesService();

  bool _isLoading = true;
  String _username = 'Student';
  String _buddyMessage = '';
  bool _showBuddy = true;
  List<_HabitUiData> _habitData = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _username = await _preferences.getUsername();
    _showBuddy = await _preferences.getHabitBuddyEnabled();

    final habits = await _repository.fetchActiveHabits();
    final today = DateTime.now().toIso8601String().split('T').first;
    final list = <_HabitUiData>[];

    for (final habit in habits) {
      list.add(
        _HabitUiData(
          habit: habit,
          streak: await _repository.getCurrentStreak(habit.id!),
          isCompletedToday: await _repository.isHabitCompletedOnDate(
            habit.id!,
            today,
          ),
        ),
      );
    }

    _habitData = list;
    _buddyMessage = await _repository.getDashboardBuddyMessage();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _openAddHabit([Habit? habit]) async {
    final result = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(builder: (_) => AddEditHabitScreen(habit: habit)),
    );

    if (result == null) return;

    if (habit == null) {
      await _repository.createHabit(result);
    } else {
      await _repository.editHabit(result);
    }

    await _load();
  }

  Future<void> _openDetails(Habit habit) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
    );
    await _load();
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete habit?'),
        content: Text('Delete ${habit.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.removeHabit(habit.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Habit deleted.')));
      await _load();
    }
  }

  Future<void> _toggleCompletion(Habit habit) async {
    await _repository.toggleHabitCompletionForToday(habit.id!);
    await _load();
  }

  Widget _buildDashboardBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome back, $_username',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text("Today's Habits"),
          const SizedBox(height: 16),
          if (_showBuddy)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_buddyMessage)),
                ],
              ),
            ),
          if (_showBuddy) const SizedBox(height: 16),
          if (_habitData.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Icon(Icons.flag_outlined, size: 40),
                    const SizedBox(height: 10),
                    const Text(
                      'No habits created yet. Tap + to add your first habit.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _openAddHabit,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Habit'),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._habitData.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HabitCard(
                  habit: item.habit,
                  streak: item.streak,
                  isCompletedToday: item.isCompletedToday,
                  onTap: () => _toggleCompletion(item.habit),
                  onView: () => _openDetails(item.habit),
                  onEdit: () => _openAddHabit(item.habit),
                  onDelete: () => _deleteHabit(item.habit),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboardBody(),
      const StatisticsScreen(),
      SettingsScreen(
        initialDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    final titles = ['Habit Mastery League', 'Statistics', 'Settings'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: IndexedStack(index: _currentIndex, children: pages),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openAddHabit,
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            _load();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _HabitUiData {
  final Habit habit;
  final int streak;
  final bool isCompletedToday;

  _HabitUiData({
    required this.habit,
    required this.streak,
    required this.isCompletedToday,
  });
}
